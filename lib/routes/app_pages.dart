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
import 'package:watibot/modules/inbox/views/image_preview_view.dart';
import 'package:watibot/modules/inbox/views/pdf_preview_view.dart';
import 'package:watibot/modules/campaigns/routes/campaigns_routes.dart';
import 'package:watibot/modules/campaigns/views/campaigns_view.dart';
import 'package:watibot/modules/campaigns/bindings/campaigns_binding.dart';
import 'package:watibot/modules/campaigns/views/campaign_details_view.dart';
import 'package:watibot/modules/contacts/routes/contacts_routes.dart';
import 'package:watibot/modules/contacts/views/contacts_view.dart';
import 'package:watibot/modules/contacts/bindings/contacts_binding.dart';
import 'package:watibot/modules/contacts/views/contact_details_view.dart';
import 'package:watibot/modules/templates/routes/templates_routes.dart';
import 'package:watibot/modules/templates/views/templates_view.dart';
import 'package:watibot/modules/templates/views/template_details_view.dart';
import 'package:watibot/modules/templates/views/create_template_view.dart';
import 'package:watibot/modules/templates/bindings/templates_binding.dart';
import 'package:watibot/modules/media_library/routes/media_library_routes.dart';
import 'package:watibot/modules/media_library/views/media_library_view.dart';
import 'package:watibot/modules/media_library/bindings/media_library_binding.dart';
import 'package:watibot/modules/agents/routes/agents_routes.dart';
import 'package:watibot/modules/agents/views/agents_view.dart';
import 'package:watibot/modules/agents/views/agent_details_view.dart';
import 'package:watibot/modules/agents/bindings/agents_binding.dart';

import 'package:watibot/modules/audience/routes/audience_routes.dart';
import 'package:watibot/modules/audience/views/audience_view.dart';
import 'package:watibot/modules/audience/views/audience_details_view.dart';
import 'package:watibot/modules/audience/bindings/audience_binding.dart';

import 'package:watibot/modules/notifications/routes/notifications_routes.dart';
import 'package:watibot/modules/notifications/views/notifications_view.dart';
import 'package:watibot/modules/notifications/bindings/notifications_binding.dart';

import 'package:watibot/modules/integrations/routes/integrations_routes.dart';
import 'package:watibot/modules/integrations/views/integrations_view.dart';
import 'package:watibot/modules/integrations/bindings/integrations_binding.dart';







import 'package:watibot/modules/home/bindings/activity_log_binding.dart';
import 'package:watibot/modules/home/views/activity_log_view.dart';

import 'package:watibot/modules/splash/routes/splash_routes.dart';


import 'package:watibot/modules/splash/views/splash_view.dart';
import 'package:watibot/modules/splash/bindings/splash_binding.dart';

class AppPages {
  static String get initial {
    return SplashRoutes.splash;
  }

  static final routes = [
    GetPage(
      name: SplashRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
    ),
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
      name: InboxRoutes.imagePreview,
      page: () => const ImagePreviewView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: InboxRoutes.pdfPreview,
      page: () => const PdfPreviewView(),
      transition: Transition.fadeIn,
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
    GetPage(
      name: TemplatesRoutes.templates,
      page: () => const TemplatesView(),
      binding: TemplatesBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: TemplatesRoutes.templateDetails,
      page: () => const TemplateDetailsView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: TemplatesRoutes.createTemplate,
      page: () => const CreateTemplateView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: MediaLibraryRoutes.mediaLibrary,
      page: () => const MediaLibraryView(),
      binding: MediaLibraryBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AgentsRoutes.agents,
      page: () => const AgentsView(),
      binding: AgentsBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AgentsRoutes.agentDetails,
      page: () => const AgentDetailsView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AudienceRoutes.audience,
      page: () => const AudienceView(),
      binding: AudienceBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AudienceRoutes.audienceDetails,
      page: () => const AudienceDetailsView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: NotificationsRoutes.notifications,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: IntegrationsRoutes.integrations,
      page: () => const IntegrationsView(),
      binding: IntegrationsBinding(),
      transition: Transition.fadeIn,
    ),
  ];
}






