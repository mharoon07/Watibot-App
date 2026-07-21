import 'package:get/get.dart';
import 'package:watibot/modules/auth/bindings/auth_binding.dart';
import 'package:watibot/modules/auth/bindings/login_binding.dart';
import 'package:watibot/modules/auth/routes/auth_routes.dart';
import 'package:watibot/modules/auth/views/login_view.dart';
import 'package:watibot/modules/auth/views/register_view.dart';
import 'package:watibot/modules/auth/bindings/forgot_password_binding.dart';
import 'package:watibot/modules/auth/views/forgot_password_view.dart';
import 'package:watibot/modules/auth/bindings/verify_email_binding.dart';
import 'package:watibot/modules/auth/views/verify_email_view.dart';
import 'package:watibot/modules/home/bindings/home_binding.dart';
import 'package:watibot/modules/home/routes/home_routes.dart';
import 'package:watibot/modules/home/views/home_view.dart';
import 'package:watibot/modules/inbox/routes/inbox_routes.dart';
import 'package:watibot/modules/inbox/views/inbox_view.dart';
import 'package:watibot/modules/inbox/bindings/inbox_binding.dart';
import 'package:watibot/modules/inbox/views/chat_view.dart';
import 'package:watibot/modules/inbox/bindings/chat_binding.dart';
import 'package:watibot/modules/campaigns/routes/campaigns_routes.dart';
import 'package:watibot/modules/campaigns/views/campaigns_view.dart';
import 'package:watibot/modules/campaigns/bindings/campaigns_binding.dart';
import 'package:watibot/modules/campaigns/views/campaign_details_view.dart';
import 'package:watibot/modules/contacts/routes/contacts_routes.dart';
import 'package:watibot/modules/contacts/views/contacts_view.dart';
import 'package:watibot/modules/contacts/bindings/contacts_binding.dart';
import 'package:watibot/modules/contacts/views/contact_details_view.dart';

import 'package:watibot/modules/home/bindings/activity_log_binding.dart';
import 'package:watibot/modules/home/views/activity_log_view.dart';
import 'package:watibot/modules/home/bindings/notifications_binding.dart';
import 'package:watibot/modules/home/views/notifications_view.dart';

class AppPages {
  static const initial = AuthRoutes.login;

  static final routes = [
    GetPage(
      name: HomeRoutes.notifications,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: HomeRoutes.activityLog,
      page: () => const ActivityLogView(),
      binding: ActivityLogBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AuthRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AuthRoutes.register,
      page: () => const RegisterView(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AuthRoutes.forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AuthRoutes.verifyEmail,
      page: () => const VerifyEmailView(),
      binding: VerifyEmailBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: HomeRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: InboxRoutes.inbox,
      page: () => const InboxView(),
      binding: InboxBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: InboxRoutes.chat,
      page: () => const ChatView(),
      binding: ChatBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: CampaignsRoutes.campaigns,
      page: () => const CampaignsView(),
      binding: CampaignsBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: CampaignsRoutes.campaignDetails,
      page: () => const CampaignDetailsView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: ContactsRoutes.contacts,
      page: () => const ContactsView(),
      binding: ContactsBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: ContactsRoutes.contactDetails,
      page: () => const ContactDetailsView(),
      transition: Transition.rightToLeft,
    ),
  ];
}
