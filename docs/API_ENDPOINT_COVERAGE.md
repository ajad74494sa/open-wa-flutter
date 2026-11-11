# OpenWA API endpoint coverage

Generated from the [official OpenWA API reference](https://docs.open-wa.org/api-reference) and its OpenAPI specification, version 0.30.0.

## Key points

- The catalog contains 206 operations across 24 modules.
- Every operation can be dispatched through `OpenWaClient.api.invoke` and the in-app Developer Console.
- Automated tests exercise the HTTP method, resolved route, API-key header, parameter handling, and body transport against a mock client.
- Mock coverage proves client dispatch and request shape only; it does not prove that a deployed server enables the route or accepts a particular account/session.
- Existing typed service methods are convenience wrappers, not generated from this specification; use the catalog dispatcher for the exact 0.30.0 route contract.
- Live server checks were not run. The server base URL and API key must be configured locally; API keys should never be pasted into source or chat.
- Tests do not invoke live destructive operations.
- `/api/metrics` additionally requires the configured metrics bearer token; enter its `Authorization` header in the Developer Console.

| Module | Method | Route | Operation ID | Description | Mock contract | Live server |
|---|---|---|---|---|---|---|
| audit | GET | `/api/audit` | `AuditController_findAll` | List audit logs with optional filters | Mock tested | Not run |
| auth | POST | `/api/auth/api-keys` | `AuthController_create` | Create a new API key (admin only) | Mock tested | Not run |
| auth | GET | `/api/auth/api-keys` | `AuthController_findAll` | List all API keys (admin only) | Mock tested | Not run |
| auth | GET | `/api/auth/api-keys/{id}` | `AuthController_findOne` | Get API key details (admin only) | Mock tested | Not run |
| auth | PUT | `/api/auth/api-keys/{id}` | `AuthController_update` | Update API key (admin only) | Mock tested | Not run |
| auth | DELETE | `/api/auth/api-keys/{id}` | `AuthController_delete` | Delete API key (admin only) | Mock tested | Not run |
| auth | POST | `/api/auth/api-keys/{id}/revoke` | `AuthController_revoke` | Revoke API key (admin only) | Mock tested | Not run |
| auth | POST | `/api/auth/validate` | `AuthValidateController_validate` | Validate an API key | Mock tested | Not run |
| sessions | POST | `/api/sessions` | `SessionController_create` | Create a new WhatsApp session | Mock tested | Not run |
| sessions | GET | `/api/sessions` | `SessionController_findAll` | List all sessions | Mock tested | Not run |
| sessions | GET | `/api/sessions/{sessionId}` | `SessionController_findOne` | Get session by ID | Mock tested | Not run |
| sessions | DELETE | `/api/sessions/{sessionId}` | `SessionController_delete` | Delete a session | Mock tested | Not run |
| sessions | GET | `/api/sessions/{sessionId}/config` | `SessionController_getConfig` | Get the tunable configuration for a session | Mock tested | Not run |
| sessions | PATCH | `/api/sessions/{sessionId}/config` | `SessionController_updateConfig` | Update the tunable configuration for a session | Mock tested | Not run |
| sessions | GET | `/api/sessions/{sessionId}/proxy` | `SessionController_getProxy` | Get the per-session egress proxy configuration (credentials masked) | Mock tested | Not run |
| sessions | PATCH | `/api/sessions/{sessionId}/proxy` | `SessionController_updateProxy` | Update the per-session egress proxy configuration | Mock tested | Not run |
| sessions | POST | `/api/sessions/{sessionId}/start` | `SessionController_start` | Start a session and initialize WhatsApp connection | Mock tested | Not run |
| sessions | POST | `/api/sessions/{sessionId}/stop` | `SessionController_stop` | Stop a session and disconnect WhatsApp | Mock tested | Not run |
| sessions | POST | `/api/sessions/{sessionId}/logout` | `SessionController_logout` | Log out of WhatsApp (unlinks this device) and stop the session | Mock tested | Not run |
| sessions | POST | `/api/sessions/{sessionId}/force-kill` | `SessionController_forceKill` | Force-kill a stuck session (SIGKILL its wedged engine, then tear it down) | Mock tested | Not run |
| sessions | GET | `/api/sessions/{sessionId}/qr` | `SessionController_getQRCode` | Get QR code for session authentication | Mock tested | Not run |
| sessions | POST | `/api/sessions/{sessionId}/pairing-code` | `SessionController_requestPairingCode` | Request an 8-char pairing code to link via phone number (alternative to QR) | Mock tested | Not run |
| sessions | GET | `/api/sessions/{sessionId}/groups` | `SessionController_getGroups` | Get all groups for a session | Mock tested | Not run |
| groups | POST | `/api/sessions/{sessionId}/groups` | `GroupController_create` | Create a new group | Mock tested | Not run |
| sessions | GET | `/api/sessions/{sessionId}/chats` | `SessionController_getChats` | Get active chats for a session | Mock tested | Not run |
| sessions | POST | `/api/sessions/{sessionId}/chats/read` | `SessionController_markChatRead` | Mark a chat as read/seen | Mock tested | Not run |
| sessions | POST | `/api/sessions/{sessionId}/presence/subscribe` | `SessionController_subscribeToPresence` | Subscribe to a chat's presence | Mock tested | Not run |
| sessions | PUT | `/api/sessions/{sessionId}/presence` | `SessionController_setOnlinePresence` | Set the account's own global presence (appear online or offline) | Mock tested | Not run |
| sessions | GET | `/api/sessions/{sessionId}/presence/{chatId}` | `SessionController_getPresence` | Read a chat's last reported presence | Mock tested | Not run |
| sessions | POST | `/api/sessions/{sessionId}/chats/unread` | `SessionController_markChatUnread` | Mark a chat as unread | Mock tested | Not run |
| sessions | DELETE | `/api/sessions/{sessionId}/chats/{chatId}/messages` | `SessionController_clearChatMessages` | Delete every message in a chat, keeping the chat itself | Mock tested | Not run |
| sessions | POST | `/api/sessions/{sessionId}/chats/archive` | `SessionController_archiveChat` | Archive or unarchive a chat | Mock tested | Not run |
| sessions | POST | `/api/sessions/{sessionId}/chats/mute` | `SessionController_muteChat` | Mute or unmute a chat | Mock tested | Not run |
| sessions | POST | `/api/sessions/{sessionId}/chats/pin` | `SessionController_pinChat` | Pin or unpin a chat at the top of the chat list | Mock tested | Not run |
| sessions | POST | `/api/sessions/{sessionId}/chats/delete` | `SessionController_deleteChat` | Delete a chat from the chat list (e.g. a group you have left) | Mock tested | Not run |
| sessions | POST | `/api/sessions/{sessionId}/chats/typing` | `SessionController_sendChatState` | Send a typing/recording presence indicator to a chat (or clear it with 'paused') | Mock tested | Not run |
| sessions | GET | `/api/sessions/stats/overview` | `SessionController_getStats` | Get session statistics for multi-session monitoring | Mock tested | Not run |
| webhooks | POST | `/api/sessions/{sessionId}/webhooks` | `WebhookController_create` | Create a webhook for the session | Mock tested | Not run |
| webhooks | GET | `/api/sessions/{sessionId}/webhooks` | `WebhookController_findBySession` | List all webhooks for a session | Mock tested | Not run |
| webhooks | GET | `/api/sessions/{sessionId}/webhooks/{id}` | `WebhookController_findOne` | Get a webhook by ID | Mock tested | Not run |
| webhooks | PUT | `/api/sessions/{sessionId}/webhooks/{id}` | `WebhookController_update` | Update a webhook | Mock tested | Not run |
| webhooks | DELETE | `/api/sessions/{sessionId}/webhooks/{id}` | `WebhookController_delete` | Delete a webhook | Mock tested | Not run |
| webhooks | POST | `/api/sessions/{sessionId}/webhooks/{id}/test` | `WebhookController_test` | Test a webhook by sending a test payload | Mock tested | Not run |
| webhooks | GET | `/api/webhooks/delivery-failures` | `WebhooksListController_deliveryFailures` | List failed or unsent webhook deliveries, most recent first | Mock tested | Not run |
| webhooks | POST | `/api/webhooks/delivery-failures/redrive` | `WebhooksListController_redriveDeliveryFailures` | Replay recorded webhook deliveries that still hold their event data | Mock tested | Not run |
| webhooks | GET | `/api/webhooks` | `WebhooksListController_findAll` | List webhooks visible to the calling key (scoped to its allowed sessions) | Mock tested | Not run |
| automation | POST | `/api/sessions/{sessionId}/automation-rules` | `AutomationRuleController_create` | Create an autoreply rule | Mock tested | Not run |
| automation | GET | `/api/sessions/{sessionId}/automation-rules` | `AutomationRuleController_findAll` | List the sessionâ€™s autoreply rules | Mock tested | Not run |
| automation | GET | `/api/sessions/{sessionId}/automation-rules/{ruleId}` | `AutomationRuleController_findOne` | Get one autoreply rule | Mock tested | Not run |
| automation | PUT | `/api/sessions/{sessionId}/automation-rules/{ruleId}` | `AutomationRuleController_update` | Update an autoreply rule | Mock tested | Not run |
| automation | DELETE | `/api/sessions/{sessionId}/automation-rules/{ruleId}` | `AutomationRuleController_remove` | Delete an autoreply rule | Mock tested | Not run |
| messages | GET | `/api/sessions/{sessionId}/messages` | `MessageController_getMessages` | Get message history for a session | Mock tested | Not run |
| messages | POST | `/api/sessions/{sessionId}/messages/send-text` | `MessageController_sendText` | Send a text message | Mock tested | Not run |
| messages | POST | `/api/sessions/{sessionId}/messages/send-template` | `MessageController_sendTemplate` | Render a stored text template and send it as a text message | Mock tested | Not run |
| messages | POST | `/api/sessions/{sessionId}/messages/send-image` | `MessageController_sendImage` | Send an image message | Mock tested | Not run |
| messages | POST | `/api/sessions/{sessionId}/messages/send-video` | `MessageController_sendVideo` | Send a video message | Mock tested | Not run |
| messages | POST | `/api/sessions/{sessionId}/messages/send-audio` | `MessageController_sendAudio` | Send an audio/voice message | Mock tested | Not run |
| messages | POST | `/api/sessions/{sessionId}/messages/send-document` | `MessageController_sendDocument` | Send a document/file | Mock tested | Not run |
| messages | POST | `/api/sessions/{sessionId}/messages/send-location` | `MessageController_sendLocation` | Send a location message | Mock tested | Not run |
| messages | POST | `/api/sessions/{sessionId}/messages/send-contact` | `MessageController_sendContact` | Send a contact card message | Mock tested | Not run |
| messages | POST | `/api/sessions/{sessionId}/messages/send-sticker` | `MessageController_sendSticker` | Send a sticker message | Mock tested | Not run |
| messages | POST | `/api/sessions/{sessionId}/messages/send-poll` | `MessageController_sendPoll` | Send a native WhatsApp poll | Mock tested | Not run |
| messages | POST | `/api/sessions/{sessionId}/messages/reply` | `MessageController_reply` | Reply to a message | Mock tested | Not run |
| messages | POST | `/api/sessions/{sessionId}/messages/click-button` | `MessageController_clickButton` | Click a button on a WhatsApp Business prompt (Baileys only) | Mock tested | Not run |
| messages | POST | `/api/sessions/{sessionId}/messages/forward` | `MessageController_forward` | Forward a message to another chat | Mock tested | Not run |
| messages | POST | `/api/sessions/{sessionId}/messages/react` | `MessageController_react` | Add or remove a reaction to a message | Mock tested | Not run |
| messages | GET | `/api/sessions/{sessionId}/messages/batch/{batchId}` | `MessageController_getBatchStatus` | Get batch processing status | Mock tested | Not run |
| messages | POST | `/api/sessions/{sessionId}/messages/batch/{batchId}/cancel` | `MessageController_cancelBatch` | Cancel a running batch | Mock tested | Not run |
| messages | GET | `/api/sessions/{sessionId}/messages/{chatId}/history` | `MessageController_getChatHistory` | Fetch chat history live from WhatsApp | Mock tested | Not run |
| messages | GET | `/api/sessions/{sessionId}/messages/{chatId}/{messageId}/reactions` | `MessageController_getReactions` | Get reactions for a specific message | Mock tested | Not run |
| messages | GET | `/api/sessions/{sessionId}/messages/{chatId}/{messageId}/receipts` | `MessageController_getReceipts` | Get delivery and read receipts for a specific message | Mock tested | Not run |
| messages | GET | `/api/sessions/{sessionId}/messages/{chatId}/{messageId}/media` | `MessageController_getChatMedia` | Download a messageâ€™s stored media | Mock tested | Not run |
| messages | POST | `/api/sessions/{sessionId}/messages/delete` | `MessageController_deleteMessage` | Delete a message | Mock tested | Not run |
| messages | POST | `/api/sessions/{sessionId}/messages/vote-poll` | `MessageController_votePoll` | Cast a vote on a poll | Mock tested | Not run |
| messages | POST | `/api/sessions/{sessionId}/messages/pin` | `MessageController_pinMessage` | Pin a message in its chat | Mock tested | Not run |
| messages | POST | `/api/sessions/{sessionId}/messages/unpin` | `MessageController_unpinMessage` | Remove a messageâ€™s pin | Mock tested | Not run |
| messages | POST | `/api/sessions/{sessionId}/messages/star` | `MessageController_starMessage` | Star or unstar a message | Mock tested | Not run |
| messages | POST | `/api/sessions/{sessionId}/messages/edit` | `MessageController_edit` | Edit the text of a message sent by this account | Mock tested | Not run |
| messages | POST | `/api/sessions/{sessionId}/messages/send-bulk` | `MessageController_sendBulk` | Send messages to multiple recipients (async batch processing) | Mock tested | Not run |
| templates | POST | `/api/sessions/{sessionId}/templates` | `TemplateController_create` | Create a message template for the session | Mock tested | Not run |
| templates | GET | `/api/sessions/{sessionId}/templates` | `TemplateController_findBySession` | List all templates for a session | Mock tested | Not run |
| templates | GET | `/api/sessions/{sessionId}/templates/{id}` | `TemplateController_findOne` | Get a template by ID | Mock tested | Not run |
| templates | PUT | `/api/sessions/{sessionId}/templates/{id}` | `TemplateController_update` | Update a template | Mock tested | Not run |
| templates | DELETE | `/api/sessions/{sessionId}/templates/{id}` | `TemplateController_delete` | Delete a template | Mock tested | Not run |
| health | GET | `/api/health` | `HealthController_check` | Basic health check | Mock tested | Not run |
| health | GET | `/api/health/live` | `HealthController_liveness` | Liveness probe for Kubernetes | Mock tested | Not run |
| health | GET | `/api/health/ready` | `HealthController_readiness` | Readiness probe â€” verifies the auth/audit + data databases respond | Mock tested | Not run |
| settings | GET | `/api/settings` | `SettingsController_get` | Get application settings | Mock tested | Not run |
| infrastructure | GET | `/api/infra/status` | `InfraStatusController_getStatus` | Get infrastructure status | Mock tested | Not run |
| infrastructure | GET | `/api/infra/engines` | `InfraStatusController_getEngines` | Get available WhatsApp engines | Mock tested | Not run |
| infrastructure | GET | `/api/infra/engines/current` | `InfraStatusController_getCurrentEngine` | Get current active engine | Mock tested | Not run |
| infrastructure | GET | `/api/infra/update-check` | `InfraStatusController_getUpdateCheck` | Compare the running version with the latest OpenWA release | Mock tested | Not run |
| infrastructure | GET | `/api/infra/health` | `InfraStatusController_healthCheck` | Health check endpoint | Mock tested | Not run |
| infrastructure | GET | `/api/infra/config` | `InfraConfigController_getConfig` | Read the effective infrastructure configuration for the dashboard form | Mock tested | Not run |
| infrastructure | PUT | `/api/infra/config` | `InfraConfigController_saveConfig` | Save infrastructure configuration to .env file | Mock tested | Not run |
| infrastructure | POST | `/api/infra/restart` | `InfraConfigController_requestRestart` | Request server restart with Docker orchestration | Mock tested | Not run |
| infrastructure | GET | `/api/infra/export-data` | `InfraDataController_exportData` | Export all data from Data DB for migration | Mock tested | Not run |
| infrastructure | POST | `/api/infra/import-data` | `InfraDataController_importData` | Import data to Data DB (replaces existing data) | Mock tested | Not run |
| infrastructure | GET | `/api/infra/storage/files/count` | `InfraStorageController_getStorageFileCount` | Get file count in current storage | Mock tested | Not run |
| infrastructure | GET | `/api/infra/storage/export` | `InfraStorageController_exportStorage` | Export all storage files as tar.gz | Mock tested | Not run |
| infrastructure | POST | `/api/infra/storage/import` | `InfraStorageController_importStorage` | Import storage files from tar.gz | Mock tested | Not run |
| contacts | GET | `/api/sessions/{sessionId}/contacts` | `ContactController_findAll` | Get all contacts for a session | Mock tested | Not run |
| contacts | GET | `/api/sessions/{sessionId}/contacts/profile-pictures` | `ContactController_getProfilePictures` | Batch-resolve profile picture URLs for up to 50 contacts | Mock tested | Not run |
| contacts | GET | `/api/sessions/{sessionId}/contacts/blocked` | `ContactController_getBlockedContacts` | List the contacts this account has blocked | Mock tested | Not run |
| contacts | GET | `/api/sessions/{sessionId}/contacts/{contactId}` | `ContactController_findOne` | Get a specific contact by ID | Mock tested | Not run |
| contacts | PUT | `/api/sessions/{sessionId}/contacts/{contactId}` | `ContactController_upsertContact` | Save a contact to the account's addressbook, or edit an existing entry | Mock tested | Not run |
| contacts | DELETE | `/api/sessions/{sessionId}/contacts/{contactId}` | `ContactController_deleteContact` | Remove a contact from the account's addressbook | Mock tested | Not run |
| contacts | GET | `/api/sessions/{sessionId}/contacts/check/{number}` | `ContactController_checkNumber` | Check if a phone number exists on WhatsApp | Mock tested | Not run |
| contacts | GET | `/api/sessions/{sessionId}/contacts/{number}/lid` | `ContactController_getContactLid` | Look up the LID of a phone number | Mock tested | Not run |
| contacts | GET | `/api/sessions/{sessionId}/contacts/{contactId}/profile-picture` | `ContactController_getProfilePicture` | Get profile picture URL for a contact | Mock tested | Not run |
| contacts | GET | `/api/sessions/{sessionId}/contacts/{contactId}/phone` | `ContactController_resolvePhone` | Resolve a contact id (e.g. an @lid) to a phone number â€” best-effort | Mock tested | Not run |
| contacts | POST | `/api/sessions/{sessionId}/contacts/{contactId}/block` | `ContactController_blockContact` | Block a contact | Mock tested | Not run |
| contacts | DELETE | `/api/sessions/{sessionId}/contacts/{contactId}/block` | `ContactController_unblockContact` | Unblock a contact | Mock tested | Not run |
| groups | GET | `/api/sessions/{sessionId}/groups/join-info` | `GroupController_joinInfo` | Preview a group from its invite code, without joining | Mock tested | Not run |
| groups | GET | `/api/sessions/{sessionId}/groups/{groupId}` | `GroupController_findOne` | Get detailed group info | Mock tested | Not run |
| groups | POST | `/api/sessions/{sessionId}/groups/join` | `GroupController_join` | Join a group via invite code | Mock tested | Not run |
| groups | GET | `/api/sessions/{sessionId}/groups/{groupId}/settings` | `GroupController_getSettings` | Get group settings (announce / locked / ephemeral timer / member-add mode) | Mock tested | Not run |
| groups | PUT | `/api/sessions/{sessionId}/groups/{groupId}/settings` | `GroupController_updateSettings` | Update group settings (announce / locked / ephemeral timer / member-add mode) | Mock tested | Not run |
| groups | POST | `/api/sessions/{sessionId}/groups/{groupId}/participants` | `GroupController_addParticipants` | Add participants to a group | Mock tested | Not run |
| groups | DELETE | `/api/sessions/{sessionId}/groups/{groupId}/participants` | `GroupController_removeParticipants` | Remove participants from a group | Mock tested | Not run |
| groups | POST | `/api/sessions/{sessionId}/groups/{groupId}/participants/promote` | `GroupController_promoteParticipants` | Promote participants to admin | Mock tested | Not run |
| groups | POST | `/api/sessions/{sessionId}/groups/{groupId}/participants/demote` | `GroupController_demoteParticipants` | Demote participants from admin | Mock tested | Not run |
| groups | GET | `/api/sessions/{sessionId}/groups/{groupId}/membership-requests` | `GroupController_getMembershipRequests` | List pending join requests for a group | Mock tested | Not run |
| groups | POST | `/api/sessions/{sessionId}/groups/{groupId}/membership-requests/approve` | `GroupController_approveMembershipRequests` | Approve pending join requests | Mock tested | Not run |
| groups | POST | `/api/sessions/{sessionId}/groups/{groupId}/membership-requests/reject` | `GroupController_rejectMembershipRequests` | Reject pending join requests | Mock tested | Not run |
| groups | PUT | `/api/sessions/{sessionId}/groups/{groupId}/subject` | `GroupController_setSubject` | Change group name/subject | Mock tested | Not run |
| groups | PUT | `/api/sessions/{sessionId}/groups/{groupId}/description` | `GroupController_setDescription` | Change group description | Mock tested | Not run |
| groups | PUT | `/api/sessions/{sessionId}/groups/{groupId}/member-label` | `GroupController_setMemberLabel` | Set this account's member label in a group | Mock tested | Not run |
| groups | POST | `/api/sessions/{sessionId}/groups/{groupId}/leave` | `GroupController_leave` | Leave a group | Mock tested | Not run |
| groups | GET | `/api/sessions/{sessionId}/groups/{groupId}/picture` | `GroupController_getPicture` | Get the group's picture URL | Mock tested | Not run |
| groups | PUT | `/api/sessions/{sessionId}/groups/{groupId}/picture` | `GroupController_setPicture` | Set the group's picture | Mock tested | Not run |
| groups | DELETE | `/api/sessions/{sessionId}/groups/{groupId}/picture` | `GroupController_deletePicture` | Remove the group's picture | Mock tested | Not run |
| groups | GET | `/api/sessions/{sessionId}/groups/{groupId}/invite-code` | `GroupController_getInviteCode` | Get group invite code/link | Mock tested | Not run |
| groups | POST | `/api/sessions/{sessionId}/groups/{groupId}/invite-code/revoke` | `GroupController_revokeInviteCode` | Revoke group invite code and generate new one | Mock tested | Not run |
| profile | PUT | `/api/sessions/{sessionId}/profile/name` | `ProfileController_setName` | Set the account display name | Mock tested | Not run |
| profile | PUT | `/api/sessions/{sessionId}/profile/status` | `ProfileController_setStatus` | Set the account about/status text | Mock tested | Not run |
| profile | PUT | `/api/sessions/{sessionId}/profile/picture` | `ProfileController_setPicture` | Set the account profile picture (URL or base64 image) | Mock tested | Not run |
| profile | DELETE | `/api/sessions/{sessionId}/profile/picture` | `ProfileController_deletePicture` | Remove the account's profile picture | Mock tested | Not run |
| calls | POST | `/api/sessions/{sessionId}/calls/link` | `CallController_createLink` | Generate a shareable WhatsApp call link | Mock tested | Not run |
| calls | POST | `/api/sessions/{sessionId}/calls/{callId}/reject` | `CallController_reject` | Reject a ringing incoming call | Mock tested | Not run |
| labels | GET | `/api/sessions/{sessionId}/labels` | `LabelController_findAll` | Get all labels (WhatsApp Business only) | Mock tested | Not run |
| labels | GET | `/api/sessions/{sessionId}/labels/{labelId}` | `LabelController_findOne` | Get a specific label by ID | Mock tested | Not run |
| labels | PUT | `/api/sessions/{sessionId}/labels/{labelId}` | `LabelController_upsertLabel` | Create or update a label | Mock tested | Not run |
| labels | DELETE | `/api/sessions/{sessionId}/labels/{labelId}` | `LabelController_deleteLabel` | Delete a label | Mock tested | Not run |
| labels | GET | `/api/sessions/{sessionId}/labels/{labelId}/chats` | `LabelController_getChatsByLabel` | Get every chat carrying a label | Mock tested | Not run |
| labels | GET | `/api/sessions/{sessionId}/labels/chat/{chatId}` | `LabelController_getChatLabels` | Get labels for a specific chat | Mock tested | Not run |
| labels | POST | `/api/sessions/{sessionId}/labels/chat/{chatId}` | `LabelController_addLabelToChat` | Add a label to a chat | Mock tested | Not run |
| labels | DELETE | `/api/sessions/{sessionId}/labels/chat/{chatId}/{labelId}` | `LabelController_removeLabelFromChat` | Remove a label from a chat | Mock tested | Not run |
| channels | GET | `/api/sessions/{sessionId}/channels` | `ChannelController_findAll` | Get all subscribed channels/newsletters | Mock tested | Not run |
| channels | POST | `/api/sessions/{sessionId}/channels` | `ChannelController_create` | Create a channel | Mock tested | Not run |
| channels | GET | `/api/sessions/{sessionId}/channels/{channelId}` | `ChannelController_findOne` | Get a specific channel by ID | Mock tested | Not run |
| channels | DELETE | `/api/sessions/{sessionId}/channels/{channelId}` | `ChannelController_unsubscribe` | Unsubscribe from a channel | Mock tested | Not run |
| channels | GET | `/api/sessions/{sessionId}/channels/{channelId}/messages` | `ChannelController_getMessages` | Get messages from a channel | Mock tested | Not run |
| channels | POST | `/api/sessions/{sessionId}/channels/{channelId}/delete` | `ChannelController_remove` | Delete a channel this account owns | Mock tested | Not run |
| channels | POST | `/api/sessions/{sessionId}/channels/{channelId}/mute` | `ChannelController_mute` | Mute or unmute a channel | Mock tested | Not run |
| channels | POST | `/api/sessions/{sessionId}/channels/{channelId}/admins/demote` | `ChannelController_demoteAdmin` | Demote a channel admin back to a subscriber | Mock tested | Not run |
| channels | POST | `/api/sessions/{sessionId}/channels/{channelId}/owner/transfer` | `ChannelController_transferOwnership` | Transfer channel ownership to another account | Mock tested | Not run |
| channels | POST | `/api/sessions/{sessionId}/channels/subscribe` | `ChannelController_subscribe` | Subscribe to a channel using invite code | Mock tested | Not run |
| statistics | GET | `/api/stats/overview` | `StatsController_getOverview` | Get overall statistics | Mock tested | Not run |
| statistics | GET | `/api/stats/messages` | `StatsController_getMessageStats` | Get message statistics with time series | Mock tested | Not run |
| statistics | GET | `/api/stats/sessions/{sessionId}` | `StatsController_getSessionStats` | Get statistics for a specific session | Mock tested | Not run |
| metrics | GET | `/api/metrics` | `MetricsController_scrape` | Prometheus metrics (requires METRICS_TOKEN bearer) | Mock tested | Not run |
| status | GET | `/api/sessions/{sessionId}/status` | `StatusController_getStatuses` | Get all contact status updates | Mock tested | Not run |
| status | GET | `/api/sessions/{sessionId}/status/{id}` | `StatusController_getContactStatus` | Get status updates from a specific contact | Mock tested | Not run |
| status | DELETE | `/api/sessions/{sessionId}/status/{id}` | `StatusController_deleteStatus` | Delete own status | Mock tested | Not run |
| status | GET | `/api/sessions/{sessionId}/status/{statusId}/media` | `StatusController_getStatusMedia` | Stream a stored status media file | Mock tested | Not run |
| status | POST | `/api/sessions/{sessionId}/status/send-text` | `StatusController_sendTextStatus` | Post a text status | Mock tested | Not run |
| status | POST | `/api/sessions/{sessionId}/status/send-image` | `StatusController_sendImageStatus` | Post an image status | Mock tested | Not run |
| status | POST | `/api/sessions/{sessionId}/status/send-video` | `StatusController_sendVideoStatus` | Post a video status | Mock tested | Not run |
| status | POST | `/api/sessions/{sessionId}/status/send-voice` | `StatusController_sendVoiceStatus` | Post an audio status as a voice note | Mock tested | Not run |
| media | GET | `/api/sessions/{sessionId}/media/convert` | `MediaController_conversionStatus` | Whether server-side media conversion is available | Mock tested | Not run |
| media | POST | `/api/sessions/{sessionId}/media/convert/voice` | `MediaController_convertVoice` | Convert audio into a WhatsApp voice note (Ogg/Opus) | Mock tested | Not run |
| media | POST | `/api/sessions/{sessionId}/media/convert/video` | `MediaController_convertVideo` | Convert video into a WhatsApp-compatible MP4 | Mock tested | Not run |
| catalog | GET | `/api/sessions/{sessionId}/catalog` | `CatalogController_getCatalog` | Get business catalog info (Baileys engine only) | Mock tested | Not run |
| catalog | GET | `/api/sessions/{sessionId}/catalog/products` | `CatalogController_getProducts` | List catalog products (Baileys engine only) | Mock tested | Not run |
| catalog | GET | `/api/sessions/{sessionId}/catalog/products/{productId}` | `CatalogController_getProduct` | Get a specific product (Baileys engine only) | Mock tested | Not run |
| catalog | POST | `/api/sessions/{sessionId}/messages/send-product` | `CatalogController_sendProduct` | Send a product message (Baileys engine only) | Mock tested | Not run |
| plugins | GET | `/api/plugins` | `PluginsController_findAll` | List all plugins | Mock tested | Not run |
| plugins | POST | `/api/plugins/install` | `PluginsController_install` | Install a plugin from an uploaded .zip package | Mock tested | Not run |
| plugins | POST | `/api/plugins/install-url` | `PluginsController_installFromUrl` | Install a plugin by downloading its .zip from a URL (SSRF-guarded) | Mock tested | Not run |
| plugins | GET | `/api/plugins/catalog` | `PluginsController_catalog` | List the remote plugin catalog, annotated with install state | Mock tested | Not run |
| plugins | GET | `/api/plugins/{id}` | `PluginsController_findOne` | Get plugin by ID | Mock tested | Not run |
| plugins | DELETE | `/api/plugins/{id}` | `PluginsController_uninstall` | Uninstall a plugin (removes its files; built-ins are protected) | Mock tested | Not run |
| plugins | POST | `/api/plugins/{id}/enable` | `PluginsController_enable` | Enable a plugin | Mock tested | Not run |
| plugins | POST | `/api/plugins/{id}/disable` | `PluginsController_disable` | Disable a plugin | Mock tested | Not run |
| plugins | PUT | `/api/plugins/{id}/config` | `PluginsController_updateConfig` | Update plugin configuration | Mock tested | Not run |
| plugins | GET | `/api/plugins/{id}/config-ui` | `PluginsController_getConfigUi` | Serve a plugin's sandboxed config-UI entry HTML (for an iframe srcdoc) | Mock tested | Not run |
| plugins | PUT | `/api/plugins/{id}/config/{sessionId}` | `PluginsController_updateSessionConfig` | Set a plugin config override for a specific session (empty = clear it) | Mock tested | Not run |
| plugins | PUT | `/api/plugins/{id}/sessions` | `PluginsController_updateSessions` | Set which sessions a session-scoped plugin is activated for (['*'] = all) | Mock tested | Not run |
| plugins | POST | `/api/plugins/{id}/update` | `PluginsController_update` | Update an installed plugin in place from a URL (preserves config + enabled state) | Mock tested | Not run |
| plugins | GET | `/api/plugins/{id}/health` | `PluginsController_healthCheck` | Check plugin health | Mock tested | Not run |
| integration | GET | `/api/ingress/{pluginId}/{instanceId}/{path}` | `IngressController_receive_get` |  | Mock tested | Not run |
| integration | POST | `/api/ingress/{pluginId}/{instanceId}/{path}` | `IngressController_receive_post` |  | Mock tested | Not run |
| integration | PUT | `/api/ingress/{pluginId}/{instanceId}/{path}` | `IngressController_receive_put` |  | Mock tested | Not run |
| integration | DELETE | `/api/ingress/{pluginId}/{instanceId}/{path}` | `IngressController_receive_delete` |  | Mock tested | Not run |
| integration | PATCH | `/api/ingress/{pluginId}/{instanceId}/{path}` | `IngressController_receive_patch` |  | Mock tested | Not run |
| integration | OPTIONS | `/api/ingress/{pluginId}/{instanceId}/{path}` | `IngressController_receive_options` |  | Mock tested | Not run |
| integration | HEAD | `/api/ingress/{pluginId}/{instanceId}/{path}` | `IngressController_receive_head` |  | Mock tested | Not run |
| integration | POST | `/api/integration/instances/{pluginId}/{instanceId}/redrive` | `RedriveController_redriveInstance` |  | Mock tested | Not run |
| integration | POST | `/api/integration/plugins/{pluginId}/instances` | `IntegrationInstanceController_create` |  | Mock tested | Not run |
| integration | GET | `/api/integration/plugins/{pluginId}/instances` | `IntegrationInstanceController_list` |  | Mock tested | Not run |
| integration | GET | `/api/integration/plugins/{pluginId}/instances/{instanceId}` | `IntegrationInstanceController_getOne` |  | Mock tested | Not run |
| integration | PATCH | `/api/integration/plugins/{pluginId}/instances/{instanceId}` | `IntegrationInstanceController_patch` |  | Mock tested | Not run |
| integration | DELETE | `/api/integration/plugins/{pluginId}/instances/{instanceId}` | `IntegrationInstanceController_remove` |  | Mock tested | Not run |
| integration | POST | `/api/integration/plugins/{pluginId}/instances/{instanceId}/regenerate-secret` | `IntegrationInstanceController_regenerate` |  | Mock tested | Not run |
| search | GET | `/api/search` | `SearchController_search` | Search messages across sessions (active search provider) | Mock tested | Not run |
