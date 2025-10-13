# Diff Details

Date : 2025-10-13 17:05:58

Directory e:\\web_project2\\pazartesi_basliyorum2\\pazartesi_basliyorum

Total : 102 files,  6739 codes, 407 comments, 912 blanks, all 8058 lines

[Summary](results.md) / [Details](details.md) / [Diff Summary](diff.md) / Diff Details

## Files
| filename | language | code | comment | blank | total |
| :--- | :--- | ---: | ---: | ---: | ---: |
| [lib/core/constants/app\_constants.dart](/lib/core/constants/app_constants.dart) | Dart | 0 | 0 | 1 | 1 |
| [lib/core/constants/firebase\_constants.dart](/lib/core/constants/firebase_constants.dart) | Dart | 0 | 0 | 1 | 1 |
| [lib/core/errors/exceptions.dart](/lib/core/errors/exceptions.dart) | Dart | -2 | 0 | 0 | -2 |
| [lib/core/errors/failures.dart](/lib/core/errors/failures.dart) | Dart | -1 | 0 | 0 | -1 |
| [lib/core/routing/app\_router.dart](/lib/core/routing/app_router.dart) | Dart | 0 | 0 | 1 | 1 |
| [lib/core/services/advanced\_statistics\_service.dart](/lib/core/services/advanced_statistics_service.dart) | Dart | 270 | 24 | 57 | 351 |
| [lib/core/services/connectivity\_service.dart](/lib/core/services/connectivity_service.dart) | Dart | 45 | 3 | 14 | 62 |
| [lib/core/services/export\_import\_service.dart](/lib/core/services/export_import_service.dart) | Dart | 221 | 27 | 45 | 293 |
| [lib/core/services/initial\_sync\_service.dart](/lib/core/services/initial_sync_service.dart) | Dart | 97 | 9 | 30 | 136 |
| [lib/core/services/notification\_service.dart](/lib/core/services/notification_service.dart) | Dart | 121 | 11 | 24 | 156 |
| [lib/core/services/push\_notification\_service.dart](/lib/core/services/push_notification_service.dart) | Dart | 72 | 16 | 23 | 111 |
| [lib/core/services/sync\_queue\_item.dart](/lib/core/services/sync_queue_item.dart) | Dart | 90 | 0 | 16 | 106 |
| [lib/core/services/sync\_service.dart](/lib/core/services/sync_service.dart) | Dart | 256 | 20 | 49 | 325 |
| [lib/core/theme/app\_colors.dart](/lib/core/theme/app_colors.dart) | Dart | 0 | 0 | 1 | 1 |
| [lib/core/theme/app\_theme.dart](/lib/core/theme/app_theme.dart) | Dart | 0 | 0 | 1 | 1 |
| [lib/core/utils/date\_utils.dart](/lib/core/utils/date_utils.dart) | Dart | 0 | 0 | 1 | 1 |
| [lib/core/utils/extensions.dart](/lib/core/utils/extensions.dart) | Dart | -2 | 0 | 1 | -1 |
| [lib/core/utils/validators.dart](/lib/core/utils/validators.dart) | Dart | 4 | 0 | 1 | 5 |
| [lib/core/widgets/initial\_sync\_dialog.dart](/lib/core/widgets/initial_sync_dialog.dart) | Dart | 129 | 2 | 12 | 143 |
| [lib/core/widgets/sync\_indicator.dart](/lib/core/widgets/sync_indicator.dart) | Dart | 212 | 2 | 22 | 236 |
| [lib/features/achievements/data/models/achievement\_model.dart](/lib/features/achievements/data/models/achievement_model.dart) | Dart | 58 | 5 | 7 | 70 |
| [lib/features/achievements/data/services/achievement\_service.dart](/lib/features/achievements/data/services/achievement_service.dart) | Dart | 171 | 14 | 26 | 211 |
| [lib/features/achievements/domain/entities/achievement.dart](/lib/features/achievements/domain/entities/achievement.dart) | Dart | 115 | 3 | 10 | 128 |
| [lib/features/achievements/presentation/providers/achievement\_provider.dart](/lib/features/achievements/presentation/providers/achievement_provider.dart) | Dart | 95 | 9 | 16 | 120 |
| [lib/features/achievements/presentation/widgets/achievement\_unlocked\_dialog.dart](/lib/features/achievements/presentation/widgets/achievement_unlocked_dialog.dart) | Dart | 128 | 6 | 16 | 150 |
| [lib/features/achievements/presentation/widgets/badge\_widget.dart](/lib/features/achievements/presentation/widgets/badge_widget.dart) | Dart | 109 | 1 | 9 | 119 |
| [lib/features/auth/data/datasources/auth\_local\_datasource.dart](/lib/features/auth/data/datasources/auth_local_datasource.dart) | Dart | 1 | 0 | 0 | 1 |
| [lib/features/auth/data/datasources/auth\_remote\_datasource.dart](/lib/features/auth/data/datasources/auth_remote_datasource.dart) | Dart | -7 | 0 | 0 | -7 |
| [lib/features/auth/data/models/user\_model.dart](/lib/features/auth/data/models/user_model.dart) | Dart | 0 | 0 | 1 | 1 |
| [lib/features/auth/domain/repositories/auth\_repository.dart](/lib/features/auth/domain/repositories/auth_repository.dart) | Dart | 0 | 0 | 1 | 1 |
| [lib/features/auth/domain/usecases/auth\_usecases.dart](/lib/features/auth/domain/usecases/auth_usecases.dart) | Dart | 0 | 0 | -4 | -4 |
| [lib/features/auth/presentation/providers/auth\_provider.dart](/lib/features/auth/presentation/providers/auth_provider.dart) | Dart | 1 | 0 | 1 | 2 |
| [lib/features/auth/presentation/screens/onboarding\_screen.dart](/lib/features/auth/presentation/screens/onboarding_screen.dart) | Dart | 0 | 0 | -1 | -1 |
| [lib/features/auth/presentation/screens/sign\_in\_screen.dart](/lib/features/auth/presentation/screens/sign_in_screen.dart) | Dart | 6 | 0 | 1 | 7 |
| [lib/features/auth/presentation/screens/sign\_up\_screen.dart](/lib/features/auth/presentation/screens/sign_up_screen.dart) | Dart | 7 | 0 | 1 | 8 |
| [lib/features/auth/presentation/screens/splash\_screen.dart](/lib/features/auth/presentation/screens/splash_screen.dart) | Dart | 0 | 0 | 1 | 1 |
| [lib/features/auth/presentation/screens/welcome\_screen.dart](/lib/features/auth/presentation/screens/welcome_screen.dart) | Dart | 0 | 0 | 1 | 1 |
| [lib/features/auth/presentation/widgets/email\_input\_field.dart](/lib/features/auth/presentation/widgets/email_input_field.dart) | Dart | 1 | 0 | 0 | 1 |
| [lib/features/auth/presentation/widgets/password\_input\_field.dart](/lib/features/auth/presentation/widgets/password_input_field.dart) | Dart | 4 | 0 | 0 | 4 |
| [lib/features/auth/presentation/widgets/social\_sign\_in\_button.dart](/lib/features/auth/presentation/widgets/social_sign_in_button.dart) | Dart | 3 | 0 | 0 | 3 |
| [lib/features/goals/data/models/goal\_model.dart](/lib/features/goals/data/models/goal_model.dart) | Dart | 123 | 5 | 10 | 138 |
| [lib/features/goals/data/repositories/goal\_repository\_impl.dart](/lib/features/goals/data/repositories/goal_repository_impl.dart) | Dart | 184 | 3 | 31 | 218 |
| [lib/features/goals/domain/entities/goal.dart](/lib/features/goals/domain/entities/goal.dart) | Dart | 92 | 6 | 8 | 106 |
| [lib/features/goals/domain/repositories/goal\_repository.dart](/lib/features/goals/domain/repositories/goal_repository.dart) | Dart | 14 | 11 | 11 | 36 |
| [lib/features/goals/presentation/providers/goal\_providers.dart](/lib/features/goals/presentation/providers/goal_providers.dart) | Dart | 35 | 10 | 12 | 57 |
| [lib/features/goals/presentation/widgets/goal\_card.dart](/lib/features/goals/presentation/widgets/goal_card.dart) | Dart | 211 | 3 | 13 | 227 |
| [lib/features/habits/data/datasources/habit\_remote\_datasource.dart](/lib/features/habits/data/datasources/habit_remote_datasource.dart) | Dart | 47 | 1 | 6 | 54 |
| [lib/features/habits/data/models/habit\_log\_model.dart](/lib/features/habits/data/models/habit_log_model.dart) | Dart | 1 | 0 | 1 | 2 |
| [lib/features/habits/data/models/habit\_model.dart](/lib/features/habits/data/models/habit_model.dart) | Dart | 6 | 0 | 1 | 7 |
| [lib/features/habits/data/models/streak\_recovery\_model.dart](/lib/features/habits/data/models/streak_recovery_model.dart) | Dart | 52 | 5 | 7 | 64 |
| [lib/features/habits/data/repositories/habit\_repository\_impl.dart](/lib/features/habits/data/repositories/habit_repository_impl.dart) | Dart | 88 | 9 | 12 | 109 |
| [lib/features/habits/data/repositories/offline\_first\_habit\_repository.dart](/lib/features/habits/data/repositories/offline_first_habit_repository.dart) | Dart | 290 | 23 | 49 | 362 |
| [lib/features/habits/domain/entities/habit.dart](/lib/features/habits/domain/entities/habit.dart) | Dart | 6 | 0 | -1 | 5 |
| [lib/features/habits/domain/entities/habit\_log.dart](/lib/features/habits/domain/entities/habit_log.dart) | Dart | 1 | 0 | -1 | 0 |
| [lib/features/habits/domain/entities/streak\_recovery.dart](/lib/features/habits/domain/entities/streak_recovery.dart) | Dart | 77 | 12 | 12 | 101 |
| [lib/features/habits/domain/repositories/habit\_repository.dart](/lib/features/habits/domain/repositories/habit_repository.dart) | Dart | 15 | 6 | 5 | 26 |
| [lib/features/habits/domain/usecases/habit\_usecases.dart](/lib/features/habits/domain/usecases/habit_usecases.dart) | Dart | 0 | 0 | -15 | -15 |
| [lib/features/habits/presentation/providers/habits\_provider.dart](/lib/features/habits/presentation/providers/habits_provider.dart) | Dart | 85 | 5 | 10 | 100 |
| [lib/features/habits/presentation/screens/create\_habit\_screen.dart](/lib/features/habits/presentation/screens/create_habit_screen.dart) | Dart | 19 | 0 | 0 | 19 |
| [lib/features/habits/presentation/screens/edit\_habit\_screen.dart](/lib/features/habits/presentation/screens/edit_habit_screen.dart) | Dart | 16 | 0 | 0 | 16 |
| [lib/features/habits/presentation/screens/habit\_detail\_screen.dart](/lib/features/habits/presentation/screens/habit_detail_screen.dart) | Dart | 485 | 9 | 32 | 526 |
| [lib/features/habits/presentation/screens/home\_screen.dart](/lib/features/habits/presentation/screens/home_screen.dart) | Dart | 0 | 0 | 1 | 1 |
| [lib/features/habits/presentation/screens/statistics\_screen.dart](/lib/features/habits/presentation/screens/statistics_screen.dart) | Dart | 136 | 14 | 29 | 179 |
| [lib/features/habits/presentation/screens/today\_screen.dart](/lib/features/habits/presentation/screens/today_screen.dart) | Dart | 162 | 14 | 17 | 193 |
| [lib/features/habits/presentation/widgets/category\_pie\_chart\_card.dart](/lib/features/habits/presentation/widgets/category_pie_chart_card.dart) | Dart | 149 | 3 | 11 | 163 |
| [lib/features/habits/presentation/widgets/daily\_progress\_card.dart](/lib/features/habits/presentation/widgets/daily_progress_card.dart) | Dart | 3 | 0 | 0 | 3 |
| [lib/features/habits/presentation/widgets/detailed\_checkin\_sheet.dart](/lib/features/habits/presentation/widgets/detailed_checkin_sheet.dart) | Dart | 3 | 0 | 0 | 3 |
| [lib/features/habits/presentation/widgets/edit\_log\_sheet.dart](/lib/features/habits/presentation/widgets/edit_log_sheet.dart) | Dart | 5 | 0 | 0 | 5 |
| [lib/features/habits/presentation/widgets/frequency\_selector.dart](/lib/features/habits/presentation/widgets/frequency_selector.dart) | Dart | 4 | 0 | 0 | 4 |
| [lib/features/habits/presentation/widgets/habit\_card.dart](/lib/features/habits/presentation/widgets/habit_card.dart) | Dart | 69 | 1 | 0 | 70 |
| [lib/features/habits/presentation/widgets/heatmap\_calendar\_card.dart](/lib/features/habits/presentation/widgets/heatmap_calendar_card.dart) | Dart | 180 | 7 | 19 | 206 |
| [lib/features/habits/presentation/widgets/monthly\_line\_chart\_card.dart](/lib/features/habits/presentation/widgets/monthly_line_chart_card.dart) | Dart | 131 | 2 | 8 | 141 |
| [lib/features/habits/presentation/widgets/progress\_ring.dart](/lib/features/habits/presentation/widgets/progress_ring.dart) | Dart | 2 | 0 | -2 | 0 |
| [lib/features/habits/presentation/widgets/skip\_reason\_sheet.dart](/lib/features/habits/presentation/widgets/skip_reason_sheet.dart) | Dart | 5 | 0 | 0 | 5 |
| [lib/features/habits/presentation/widgets/streak\_recovery\_dialog.dart](/lib/features/habits/presentation/widgets/streak_recovery_dialog.dart) | Dart | 248 | 15 | 12 | 275 |
| [lib/features/habits/presentation/widgets/weekly\_bar\_chart\_card.dart](/lib/features/habits/presentation/widgets/weekly_bar_chart_card.dart) | Dart | 127 | 2 | 10 | 139 |
| [lib/features/profile/presentation/screens/profile\_screen.dart](/lib/features/profile/presentation/screens/profile_screen.dart) | Dart | 124 | 1 | 5 | 130 |
| [lib/features/social/data/models/friend\_model.dart](/lib/features/social/data/models/friend_model.dart) | Dart | 69 | 5 | 8 | 82 |
| [lib/features/social/data/models/shared\_habit\_model.dart](/lib/features/social/data/models/shared_habit_model.dart) | Dart | 54 | 5 | 6 | 65 |
| [lib/features/social/data/repositories/friend\_repository\_impl.dart](/lib/features/social/data/repositories/friend_repository_impl.dart) | Dart | 184 | 12 | 38 | 234 |
| [lib/features/social/data/repositories/shared\_habit\_repository\_impl.dart](/lib/features/social/data/repositories/shared_habit_repository_impl.dart) | Dart | 136 | 7 | 26 | 169 |
| [lib/features/social/data/repositories/user\_search\_repository.dart](/lib/features/social/data/repositories/user_search_repository.dart) | Dart | 59 | 7 | 15 | 81 |
| [lib/features/social/domain/entities/friend.dart](/lib/features/social/domain/entities/friend.dart) | Dart | 50 | 2 | 4 | 56 |
| [lib/features/social/domain/entities/shared\_habit.dart](/lib/features/social/domain/entities/shared_habit.dart) | Dart | 57 | 1 | 3 | 61 |
| [lib/features/social/domain/repositories/friend\_repository.dart](/lib/features/social/domain/repositories/friend_repository.dart) | Dart | 13 | 10 | 10 | 33 |
| [lib/features/social/domain/repositories/shared\_habit\_repository.dart](/lib/features/social/domain/repositories/shared_habit_repository.dart) | Dart | 14 | 7 | 7 | 28 |
| [lib/features/social/presentation/providers/social\_providers.dart](/lib/features/social/presentation/providers/social_providers.dart) | Dart | 67 | 21 | 25 | 113 |
| [lib/features/social/presentation/screens/social\_screen.dart](/lib/features/social/presentation/screens/social_screen.dart) | Dart | 193 | -1 | 27 | 219 |
| [lib/features/social/presentation/widgets/add\_friend\_dialog.dart](/lib/features/social/presentation/widgets/add_friend_dialog.dart) | Dart | 155 | 3 | 17 | 175 |
| [lib/features/social/presentation/widgets/friend\_list\_item.dart](/lib/features/social/presentation/widgets/friend_list_item.dart) | Dart | 45 | 2 | 7 | 54 |
| [lib/features/social/presentation/widgets/friend\_request\_card.dart](/lib/features/social/presentation/widgets/friend_request_card.dart) | Dart | 86 | 1 | 6 | 93 |
| [lib/features/social/presentation/widgets/shared\_habit\_card.dart](/lib/features/social/presentation/widgets/shared_habit_card.dart) | Dart | 107 | 1 | 6 | 114 |
| [lib/features/statistics/presentation/screens/statistics\_screen.dart](/lib/features/statistics/presentation/screens/statistics_screen.dart) | Dart | 14 | 0 | 1 | 15 |
| [lib/generated/intl/messages\_all.dart](/lib/generated/intl/messages_all.dart) | Dart | 2 | 0 | 0 | 2 |
| [lib/generated/l10n.dart](/lib/generated/l10n.dart) | Dart | 4 | 0 | 0 | 4 |
| [lib/main.dart](/lib/main.dart) | Dart | 24 | 5 | 8 | 37 |
| [lib/shared/models/result.dart](/lib/shared/models/result.dart) | Dart | 0 | 0 | 1 | 1 |
| [lib/shared/widgets/custom\_button.dart](/lib/shared/widgets/custom_button.dart) | Dart | 1 | 0 | 0 | 1 |
| [lib/shared/widgets/custom\_text\_field.dart](/lib/shared/widgets/custom_text_field.dart) | Dart | -2 | 0 | 0 | -2 |
| [lib/shared/widgets/error\_widget.dart](/lib/shared/widgets/error_widget.dart) | Dart | 0 | 0 | -1 | -1 |
| [lib/shared/widgets/loading\_indicator.dart](/lib/shared/widgets/loading_indicator.dart) | Dart | 0 | 0 | -1 | -1 |
| [pubspec.yaml](/pubspec.yaml) | YAML | 8 | 0 | 0 | 8 |

[Summary](results.md) / [Details](details.md) / [Diff Summary](diff.md) / Diff Details