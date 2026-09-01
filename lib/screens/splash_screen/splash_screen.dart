import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:hyper_local/bloc/settings_bloc/settings_bloc.dart';
import 'package:hyper_local/router/app_routes.dart';
import 'package:hyper_local/screens/home_page/bloc/brands/brands_bloc.dart';
import 'package:hyper_local/screens/user_profile/bloc/user_profile_bloc/user_profile_bloc.dart';
import 'package:hyper_local/utils/widgets/custom_image_container.dart';
import 'package:hyper_local/utils/widgets/custom_scaffold.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../bloc/user_details_bloc/user_details_bloc.dart';
import '../../bloc/user_details_bloc/user_details_state.dart';
import '../../config/global.dart';
import '../../config/helper.dart';
import '../../config/notification_service.dart';
import '../../config/settings_data_instance.dart';
import '../../config/theme.dart';
import '../../services/location/location_service.dart';
import '../home_page/bloc/banner/banner_bloc.dart';
import '../home_page/bloc/banner/banner_event.dart';
import '../home_page/bloc/category/category_bloc.dart';
import '../home_page/bloc/category/category_event.dart';
import '../home_page/bloc/feature_section_product/feature_section_product_bloc.dart';
import '../home_page/bloc/feature_section_product/feature_section_product_event.dart';
import '../home_page/bloc/sub_category/sub_category_bloc.dart';
import '../home_page/bloc/sub_category/sub_category_event.dart';
import '../../deep_link.dart';


import 'package:hyper_local/l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasInitialized = false;
  bool _hasNavigated = false;
  bool _lastKnownConnectivity = false;

  @override
  void initState() {
    super.initState();
    getFcm();
    // Dispatch initial settings fetch immediately
    context.read<SettingsBloc>().add(FetchSettingsData(context: context));
  }


  Future<String?> getFcm () async {
    String? fcmToken = await getFCMToken();
    return fcmToken.toString();
  }

  // Helper method to show the location access dialog
  Future<bool?> _showLocationAccessDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(dialogContext)!.locationAccessNeeded),
        content: Text(
          AppLocalizations.of(dialogContext)!.locationAccessDescription,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(AppLocalizations.of(dialogContext)!.later),
          ),
          TextButton(
            onPressed: () async {
              await Geolocator.openLocationSettings();
              if(dialogContext.mounted) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: Text(AppLocalizations.of(dialogContext)!.openSettings),
          ),
          TextButton(
            onPressed: () async {
              await openAppSettings();
              if(dialogContext.mounted) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: Text(AppLocalizations.of(dialogContext)!.appPermissions),
          ),
        ],
      ),
    );
  }

  // Modified to use SettingsData.instance directly
  Future<void> _checkAndSetLocation() async {
    // Check if we can skip all location logic based on current stored state
    // Skip this check if we are in Demo Mode, as Demo Mode forces a default location.
    if (!AppHelpers.isDemo && LocationService.hasStoredLocation()) {
      // Location already set and we are NOT in demo mode, so we are done.
      return;
    }

    String? lat, lng;

    // --- 1. Try getting location from SettingsData singleton (Web Settings) ---
    // Note: You specified SettingsData.instance.web instead of .system
    final webSettings = SettingsData.instance.web;
    if (webSettings != null) {
      lat = webSettings.defaultLatitude;
      lng = webSettings.defaultLongitude;
    }

    // Check if we got a valid location from settings
    if (lat != null && lng != null && lat.isNotEmpty && lng.isNotEmpty) {
      // Use the new function to store location with geocoding
      await LocationService.storeLocationFromCoordinates(
        latitude: lat,
        longitude: lng,
      );
      return;
    }

    // --- 2. Fallback to Demo Location (if isDemo is true) ---
    if (AppHelpers.isDemo) {
      lat = AppHelpers.defaultLat;
      lng = AppHelpers.defaultLng;

      if (lat.isNotEmpty && lng.isNotEmpty) {
        // Since we skipped the initial hasStoredLocation check for isDemo == true,
        // this location will be stored regardless of what was previously in Hive.
        await LocationService.storeLocationFromCoordinates(
          latitude: lat,
          longitude: lng,
        );
        return;
      }
      // If AppConstant.isDemo is true but defaultLat/Lng are empty, we fall through to step 3.
    }

    // --- 3. Get Current Location (Default behavior for non-demo mode or if all fallbacks failed) ---
    // This step runs only if:
    // a) AppConstant.isDemo is false AND no location is stored.
    // b) AppConstant.isDemo is true but neither settings nor AppConstant provided valid coordinates.
    if (!LocationService.hasStoredLocation()) {
      final bool? granted = await _showLocationAccessDialog();

      if (granted == true) {
        final currentLoc = await LocationService.requestAndStoreLocationWithRetry();
        if (currentLoc == null) {
          // Handle case where location services are off or permission is denied after prompt
        }
      } else {
        // User pressed 'Later'
      }
    }
  }

  Future<void> navigate() async {
    _dispatchInitialDataFetches();
    if (_hasNavigated) {
      return;
    }
    _hasNavigated = true;
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted || !_lastKnownConnectivity) {
      _hasNavigated = false;
      return;
    }


    // If first launch -> show intro slider
    if (Global.isFirstTime) {
      GoRouter.of(context).go(AppRoutes.introSlider);
      return;
    }

    // Not first launch: if logged in, go to home
/*    if (Global.userData?.token.isNotEmpty ?? false) {
      if (mounted) {
        GoRouter.of(context).go(AppRoutes.home);
      }
    } else {
      // Not logged in -> go to login
      GoRouter.of(context).go(AppRoutes.login);
    }*/

    // If a deep link is being handled, let it take control of navigation
    if (AppLinksDeepLink.instance.hasPendingLink) {
      log('Deep link pending, skipping splash screen navigation');
      return;
    }

    GoRouter.of(context).go(AppRoutes.home);

  }

  void _handleConnectivityChanged(bool isConnected) {
    _lastKnownConnectivity = isConnected;

    if (!isConnected) {
      _hasNavigated = false;
      // You might want to show an offline UI here
      return;
    }

    // Hide offline UI here

    if (!_hasInitialized) {
      _hasInitialized = true;
      navigate();
      return;
    }

    if (!_hasNavigated) {
      navigate();
    }
  }

  void _dispatchInitialDataFetches() {
    // Settings data is already being fetched in initState.
    context.read<CategoryBloc>().add(FetchCategory(context: context));
    // context.read<CartBloc>().add(LoadCart());
    // context.read<GetUserCartBloc>().add(FetchUserCart());
    context.read<BannerBloc>().add(FetchBanner(categorySlug: ""));
    context.read<BrandsBloc>().add(const FetchBrands(categorySlug: ""));
    context.read<SubCategoryBloc>().add(FetchSubCategory(slug: "", isForAllCategory: true));
    context
        .read<FeatureSectionProductBloc>()
        .add(FetchFeatureSectionProducts(slug: ""));
    context.read<UserProfileBloc>().add(FetchUserProfile());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      // Listen for the settings data to be loaded
      listener: (context, state) async {
        if(state is MaintenanceModeEnabled){
          GoRouter.of(context).go(
            AppRoutes.maintenancePage,
            extra: {
              'message':state.maintenanceModeMessage
            }
          );
          return;
        }
        if (state is SettingsLoaded) {
          if(SettingsData.instance.system!.webMaintenanceMode) {
            GoRouter.of(context).go(AppRoutes.maintenancePage,);
            return;
          }
          // 1. Check/Set location using SettingsData.instance
          await _checkAndSetLocation();

          // 2. Now that settings and initial location logic is done, proceed with navigation logic
          if (_lastKnownConnectivity) {
            // If connectivity check already ran (before settings loaded), trigger navigation now
            _handleConnectivityChanged(true);
          }
        }
      },
      child: BlocListener<UserDataBloc, UserDataState>(
        listener: (BuildContext context, UserDataState state) {
          // Your existing UserDataBloc listener logic if needed
        },
        child: CustomScaffold(
          showViewCart: false,
          notifyConnectivityStatusOnInit: true,
          onConnectivityChanged: (isConnected, _) {
            _lastKnownConnectivity = isConnected;
            // Only proceed with navigation if settings have already been loaded,
            // or if the settings bloc listener hasn't run yet (it will handle navigation then).
            if (context.read<SettingsBloc>().state is SettingsLoaded) {
              Future.delayed(const Duration(seconds: 1)); // Small delay for UI/Splash
              _handleConnectivityChanged(isConnected);
            }
          },
          body: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  image: DecorationImage(
                    image: AssetImage('assets/images/doodle.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: CustomImageContainer(
                      imagePath: getAppLogoUrl(context, forBrandBackground: true),
                      height: 120,
                      width: 280,
                      fit: BoxFit.contain,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}