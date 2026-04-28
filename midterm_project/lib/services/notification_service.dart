import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static Future<void> initializeNotification() async {
    // Initialize Awesome Notifications
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'basic_channel_group',
          channelKey: 'basic_channel',
          channelName: 'Client Notifications',
          channelDescription: 'Notifications untuk Client Manager',
          defaultColor: const Color(0xFF2196F3),
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          playSound: true,
          criticalAlerts: true,
        )
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'basic_channel_group',
          channelGroupName: 'Client Notifications',
        )
      ],
      debug: true,
    );

    // Request notification permissions
    await AwesomeNotifications().isNotificationAllowed().then(
      (isAllowed) {
        if (!isAllowed) {
          AwesomeNotifications().requestPermissionToSendNotifications();
        }
      },
    );

    // Set notification listeners
    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: _onActionReceivedMethod,
      onNotificationCreatedMethod: _onNotificationCreateMethod,
      onNotificationDisplayedMethod: _onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: _onDismissActionReceivedMethod,
    );
  }

  // Listeners
  static Future<void> _onNotificationCreateMethod(
    ReceivedNotification receivedNotification,
  ) async {
    debugPrint('Notification created: ${receivedNotification.title}');
  }

  static Future<void> _onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    debugPrint('Notification displayed: ${receivedNotification.title}');
  }

  static Future<void> _onDismissActionReceivedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    debugPrint('Notification dismissed: ${receivedNotification.title}');
  }

  static Future<void> _onActionReceivedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    debugPrint('Notification action received: ${receivedNotification.title}');
  }

  // ✅ SUCCESS NOTIFICATION - Client ditambahkan
  static Future<void> showClientAddedNotification(String clientName) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'basic_channel',
        title: '✅ Client Ditambahkan',
        body: 'Client "$clientName" berhasil ditambahkan',
        notificationLayout: NotificationLayout.Default,
        backgroundColor: Colors.green,
      ),
    );
  }

  // ✅ SUCCESS NOTIFICATION - Client diupdate
  static Future<void> showClientUpdatedNotification(String clientName) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 2,
        channelKey: 'basic_channel',
        title: '✅ Client Diperbarui',
        body: 'Client "$clientName" berhasil diperbarui',
        notificationLayout: NotificationLayout.Default,
        backgroundColor: Colors.green,
      ),
    );
  }

  // ❌ ERROR NOTIFICATION
  static Future<void> showErrorNotification(String errorMessage) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 3,
        channelKey: 'basic_channel',
        title: '❌ Terjadi Error',
        body: errorMessage,
        notificationLayout: NotificationLayout.Default,
        backgroundColor: Colors.red,
      ),
    );
  }

  // 🗑️ DELETE NOTIFICATION
  static Future<void> showClientDeletedNotification(String clientName) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 4,
        channelKey: 'basic_channel',
        title: '🗑️ Client Dihapus',
        body: 'Client "$clientName" berhasil dihapus',
        notificationLayout: NotificationLayout.Default,
        backgroundColor: Colors.orange,
      ),
    );
  }

  // 📸 PHOTO NOTIFICATION
  static Future<void> showPhotoSavedNotification() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 5,
        channelKey: 'basic_channel',
        title: '📸 Foto Berhasil Disimpan',
        body: 'Foto client berhasil disimpan',
        notificationLayout: NotificationLayout.Default,
        backgroundColor: Colors.blue,
      ),
    );
  }
}