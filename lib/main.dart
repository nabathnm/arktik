import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:arktik/features/destination/domain/usecases/get_all_destinations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/constants/app_env.dart';

import 'features/destination/data/datasources/destination_remote_datasource.dart';
import 'features/destination/data/repositories/destination_repository_impl.dart';
import 'features/destination/domain/repositories/destination_repository.dart';

import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/domain/usecases/observe_auth_state.dart';
import 'features/auth/domain/usecases/sign_in_with_google.dart';
import 'features/auth/domain/usecases/sign_out.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

import 'features/google_calendar/data/datasources/google_calendar_remote_datasource.dart';
import 'features/google_calendar/data/repositories/google_calendar_repository_impl.dart';
import 'features/google_calendar/domain/repositories/google_calendar_repository.dart';
import 'features/google_calendar/domain/usecases/calendar_usecases.dart';
import 'features/google_calendar/domain/usecases/get_availability.dart';
import 'features/google_calendar/presentation/providers/google_calendar_provider.dart';
import 'features/google_calendar/presentation/providers/availability_provider.dart';

import 'features/destination/domain/usecases/create_destination.dart';
import 'features/destination/domain/usecases/delete_destination.dart';
import 'features/destination/domain/usecases/get_destinations.dart';
import 'features/destination/domain/usecases/update_destination.dart';
import 'features/destination/presentation/providers/destination_provider.dart';

import 'features/trip/data/datasources/invitation_remote_datasource.dart';
import 'features/trip/data/repositories/invitation_repository_impl.dart';
import 'features/trip/domain/repositories/invitation_repository.dart';
import 'features/trip/domain/usecases/create_invitation.dart';
import 'features/trip/domain/usecases/get_invitation_by_code.dart';
import 'features/trip/domain/usecases/join_invitation.dart';
import 'features/trip/domain/usecases/leave_invitation.dart';
import 'features/trip/domain/usecases/close_invitation.dart';
import 'features/trip/domain/usecases/get_my_invitations.dart';
import 'features/trip/presentation/pages/invitation_provider.dart';

import 'features/trip/data/datasources/trip_remote_data_source.dart';
import 'features/trip/data/repositories/trip_repository_impl.dart';
import 'features/trip/domain/repositories/trip_repository.dart';
import 'features/trip/domain/usecases/create_trip_usecase.dart';
import 'features/trip/domain/usecases/delete_trip_usecase.dart';
import 'features/trip/domain/usecases/get_my_membership_usecase.dart';
import 'features/trip/domain/usecases/get_my_trips_usecase.dart';
import 'features/trip/domain/usecases/get_trip_by_id_usecase.dart';
import 'features/trip/domain/usecases/get_trip_leader_usecase.dart';
import 'features/trip/domain/usecases/get_trip_members_usecase.dart';
import 'features/trip/domain/usecases/leave_trip_usecase.dart';
import 'features/trip/domain/usecases/remove_trip_member_usecase.dart';
import 'features/trip/domain/usecases/add_destination_to_trip_usecase.dart';
import 'features/trip/domain/usecases/get_trip_itineraries_usecase.dart';
import 'features/trip/domain/usecases/remove_destination_from_trip_usecase.dart';
import 'features/trip/domain/usecases/update_trip_checklist_usecase.dart';
import 'features/trip/presentation/providers/trip_provider.dart';

import 'features/trip/domain/repositories/schedule_matching_repository.dart';
import 'features/trip/data/repositories/schedule_matching_repository_impl.dart';
import 'features/trip/domain/usecases/find_available_dates_usecase.dart';
import 'features/trip/domain/usecases/select_trip_date_usecase.dart';
import 'features/trip/presentation/providers/schedule_matching_provider.dart';

class Config {
  Config();

  late final SharedPreferences sharedPreferences;
  late final SupabaseClient supabase;
  late final GoogleSignIn googleSignIn;

  // Auth
  late final AuthRemoteDataSource authRemoteDataSource;
  late final AuthRepository authRepository;
  late final GetCurrentUser getCurrentUser;
  late final SignInWithGoogle signInWithGoogle;
  late final SignOut signOut;
  late final ObserveAuthState observeAuthState;

  // Provider (Singleton for Router access)
  late final AuthProvider authProvider;

  late final DestinationRemoteDatasource destinationRemoteDataSource;
  late final DestinationRepository destinationRepository;
  late final GetAllDestinations getAllDestinations;

  // Google Calendar
  late final GoogleCalendarRemoteDataSource calendarRemoteDataSource;
  late final GoogleCalendarRepository calendarRepository;
  late final GetCalendarEvents getCalendarEvents;
  late final CreateCalendarEvent createCalendarEvent;
  late final UpdateCalendarEvent updateCalendarEvent;
  late final DeleteCalendarEvent deleteCalendarEvent;
  late final GetAvailability getAvailability;
  late final SyncSchedulesToDatabase syncSchedulesToDatabase;
  late final GoogleCalendarProvider googleCalendarProvider;
  late final AvailabilityProvider availabilityProvider;

  // Admin
  late final GetDestinations getDestinations;
  late final CreateDestination createDestination;
  late final UpdateDestination updateDestination;
  late final DeleteDestination deleteDestination;
  late final DestinationProvider destinationProvider;

  // Invitation
  late final InvitationRemoteDataSource invitationRemoteDataSource;
  late final InvitationRepository invitationRepository;
  late final CreateInvitation createInvitation;
  late final GetInvitationByCode getInvitationByCode;
  late final JoinInvitation joinInvitation;
  late final LeaveInvitation leaveInvitation;
  late final CloseInvitation closeInvitation;
  late final GetMyInvitations getMyInvitations;
  late final InvitationProvider invitationProvider;

  // Trip
  late final TripRemoteDataSource tripRemoteDataSource;
  late final TripRepository tripRepository;
  late final CreateTripUseCase createTripUseCase;
  late final GetMyTripsUseCase getMyTripsUseCase;
  late final GetTripMembersUseCase getTripMembersUseCase;
  late final GetTripLeaderUseCase getTripLeaderUseCase;
  late final GetMyMembershipUseCase getMyMembershipUseCase;
  late final GetTripByIdUseCase getTripByIdUseCase;
  late final RemoveTripMemberUseCase removeTripMemberUseCase;
  late final LeaveTripUseCase leaveTripUseCase;
  late final DeleteTripUseCase deleteTripUseCase;
  late final UpdateTripChecklistUseCase updateTripChecklistUseCase;
  late final TripProvider tripProvider;

  // Schedule Matching
  late final ScheduleMatchingRepository scheduleMatchingRepository;
  late final FindAvailableDatesUseCase findAvailableDatesUseCase;
  late final SelectTripDateUseCase selectTripDateUseCase;
  late final ScheduleMatchingProvider scheduleMatchingProvider;

  Future<void> init() async {
    supabase = Supabase.instance.client;
    googleSignIn = GoogleSignIn(
      clientId: kIsWeb ? EnvConstants.googleWebClientId : null,
      serverClientId: EnvConstants.googleWebClientId,
      scopes: [
        'email',
        'https://www.googleapis.com/auth/calendar.events',
        'https://www.googleapis.com/auth/calendar.readonly',
      ],
    );

    authRemoteDataSource = AuthRemoteDataSourceImpl(supabase, googleSignIn);
    authRepository = AuthRepositoryImpl(authRemoteDataSource);

    getCurrentUser = GetCurrentUser(authRepository);
    signInWithGoogle = SignInWithGoogle(authRepository);
    signOut = SignOut(authRepository);
    observeAuthState = ObserveAuthState(authRepository);

    authProvider = AuthProvider(
      signInWithGoogle: signInWithGoogle,
      signOut: signOut,
      observeAuthState: observeAuthState,
    );

    // Discovery Initialization
    destinationRemoteDataSource = DestinationRemoteDatasource(supabase);

    final destinationRepositoryImpl = DestinationRepositoryImpl(
      destinationRemoteDatasource: destinationRemoteDataSource,
    );

    destinationRepository = destinationRepositoryImpl;

    getAllDestinations = GetAllDestinations(destinationRepository);

    // Google Calendar Initialization
    calendarRemoteDataSource = GoogleCalendarRemoteDataSourceImpl(googleSignIn);
    calendarRepository = GoogleCalendarRepositoryImpl(
      calendarRemoteDataSource,
      supabase,
    );

    getCalendarEvents = GetCalendarEvents(calendarRepository);
    createCalendarEvent = CreateCalendarEvent(calendarRepository);
    updateCalendarEvent = UpdateCalendarEvent(calendarRepository);
    deleteCalendarEvent = DeleteCalendarEvent(calendarRepository);
    getAvailability = GetAvailability(calendarRepository);
    syncSchedulesToDatabase = SyncSchedulesToDatabase(calendarRepository);

    googleCalendarProvider = GoogleCalendarProvider(
      getEvents: getCalendarEvents,
      createEvent: createCalendarEvent,
      updateEvent: updateCalendarEvent,
      deleteEvent: deleteCalendarEvent,
      syncSchedules: syncSchedulesToDatabase,
    );

    availabilityProvider = AvailabilityProvider(getAvailability);

    // Admin Initialization
    getDestinations = GetDestinations(destinationRepository);
    createDestination = CreateDestination(destinationRepository);
    updateDestination = UpdateDestination(destinationRepository);
    deleteDestination = DeleteDestination(destinationRepository);
    destinationProvider = DestinationProvider(
      repository: destinationRepository,
    );

    // Invitation Initialization
    invitationRemoteDataSource = InvitationRemoteDataSourceImpl(supabase);
    invitationRepository = InvitationRepositoryImpl(invitationRemoteDataSource);

    createInvitation = CreateInvitation(invitationRepository);
    getInvitationByCode = GetInvitationByCode(invitationRepository);
    joinInvitation = JoinInvitation(invitationRepository);
    leaveInvitation = LeaveInvitation(invitationRepository);
    closeInvitation = CloseInvitation(invitationRepository);
    getMyInvitations = GetMyInvitations(invitationRepository);

    invitationProvider = InvitationProvider(
      createInvitationUseCase: createInvitation,
      getInvitationByCodeUseCase: getInvitationByCode,
      joinInvitationUseCase: joinInvitation,
      leaveInvitationUseCase: leaveInvitation,
      closeInvitationUseCase: closeInvitation,
      getMyInvitationsUseCase: getMyInvitations,
      repository: invitationRepository,
    );

    // Trip Initialization
    tripRemoteDataSource = TripRemoteDataSourceImpl(supabase);
    tripRepository = TripRepositoryImpl(tripRemoteDataSource);
    createTripUseCase = CreateTripUseCase(tripRepository);
    getMyTripsUseCase = GetMyTripsUseCase(tripRepository);
    getTripMembersUseCase = GetTripMembersUseCase(tripRepository);
    getTripLeaderUseCase = GetTripLeaderUseCase(tripRepository);
    getMyMembershipUseCase = GetMyMembershipUseCase(tripRepository);
    getTripByIdUseCase = GetTripByIdUseCase(tripRepository);
    removeTripMemberUseCase = RemoveTripMemberUseCase(tripRepository);
    leaveTripUseCase = LeaveTripUseCase(tripRepository);
    deleteTripUseCase = DeleteTripUseCase(tripRepository);
    final addDestinationToTripUseCase = AddDestinationToTripUseCase(
      tripRepository,
    );
    final getTripItinerariesUseCase = GetTripItinerariesUseCase(tripRepository);
    final removeDestinationFromTripUseCase = RemoveDestinationFromTripUseCase(
      tripRepository,
    );
    updateTripChecklistUseCase = UpdateTripChecklistUseCase(tripRepository);

    tripProvider = TripProvider(
      createTripUseCase: createTripUseCase,
      getMyTripsUseCase: getMyTripsUseCase,
      getTripMembersUseCase: getTripMembersUseCase,
      getTripLeaderUseCase: getTripLeaderUseCase,
      getMyMembershipUseCase: getMyMembershipUseCase,
      getTripByIdUseCase: getTripByIdUseCase,
      removeTripMemberUseCase: removeTripMemberUseCase,
      leaveTripUseCase: leaveTripUseCase,
      deleteTripUseCase: deleteTripUseCase,
      addDestinationToTripUseCase: addDestinationToTripUseCase,
      getTripItinerariesUseCase: getTripItinerariesUseCase,
      removeDestinationFromTripUseCase: removeDestinationFromTripUseCase,
      updateTripChecklistUseCase: updateTripChecklistUseCase,
    );

    // Schedule Matching Initialization
    scheduleMatchingRepository = ScheduleMatchingRepositoryImpl(
      supabase,
      tripRepository,
      calendarRepository,
    );
    findAvailableDatesUseCase = FindAvailableDatesUseCase(
      scheduleMatchingRepository,
    );
    selectTripDateUseCase = SelectTripDateUseCase(scheduleMatchingRepository);

    scheduleMatchingProvider = ScheduleMatchingProvider(
      findAvailableDatesUseCase: findAvailableDatesUseCase,
      selectTripDateUseCase: selectTripDateUseCase,
    );
  }
}

final config = Config();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Warning: .env file not found. Using empty or fallback values.");
  }

  // Initialize SharedPreferences
  config.sharedPreferences = await SharedPreferences.getInstance();

  // Initialize Supabase
  await Supabase.initialize(
    url: EnvConstants.supabaseUrl,
    publishableKey: EnvConstants.supabaseAnonKey,
  );

  // Initialize Dependency Config
  await config.init();

  runApp(const App());
}
