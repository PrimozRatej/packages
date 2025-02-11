// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.quickactions;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.res.Resources;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import androidx.annotation.ChecksSdkIntAtLeast;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.pm.ShortcutInfoCompat;
import androidx.core.content.pm.ShortcutManagerCompat;
import androidx.core.graphics.drawable.IconCompat;
import io.flutter.plugins.quickactions.Messages.AndroidQuickActionsApi;
import io.flutter.plugins.quickactions.Messages.FlutterError;
import io.flutter.plugins.quickactions.Messages.Result;
import io.flutter.plugins.quickactions.Messages.ShortcutItemMessage;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Executor;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Base64;

final class QuickActions implements AndroidQuickActionsApi {
  protected static final String EXTRA_ACTION = "some unique action key";

  private final Context context;
  private Activity activity;

  QuickActions(Context context) {
    this.context = context;
  }

  void setActivity(Activity activity) {
    this.activity = activity;
  }

  public Activity getActivity() {
    return this.activity;
  }

  // Returns true when running on a version of Android that supports quick
  // actions.
  // When this returns false, methods should silently no-op, per the documented
  // behavior (see README.md).
  @ChecksSdkIntAtLeast(api = Build.VERSION_CODES.N_MR1)
  boolean isVersionAllowed() {
    return Build.VERSION.SDK_INT >= Build.VERSION_CODES.N_MR1;
  }

  @Override
  public void setShortcutItems(
      @NonNull List<ShortcutItemMessage> itemsList, @NonNull Result<Void> result) {
        System.out.println("MD2222 - Helllooooo");
    if (!isVersionAllowed()) {
      result.success(null);
      return;
    }
    System.out.println("MD2222 - 1111");
    List<ShortcutInfoCompat> shortcuts = shortcutItemMessageToShortcutInfo(itemsList);
    Executor uiThreadExecutor = new UiThreadExecutor();
    ThreadPoolExecutor executor = new ThreadPoolExecutor(0, 1, 1, TimeUnit.SECONDS, new LinkedBlockingQueue<>());
    executor.execute(
        () -> {
          boolean dynamicShortcutsSet = false;
          try {
            ShortcutManagerCompat.setDynamicShortcuts(context, shortcuts);
            dynamicShortcutsSet = true;
          } catch (Exception e) {
            // Leave dynamicShortcutsSet as false
          }

          final boolean didSucceed = dynamicShortcutsSet;

          // TODO(camsim99): Investigate removing all of the executor logic in favor of
          // background channels.
          uiThreadExecutor.execute(
              () -> {
                if (didSucceed) {
                  result.success(null);
                } else {
                  result.error(
                      new FlutterError(
                          "quick_action_setshortcutitems_failure",
                          "Exception thrown when setting dynamic shortcuts",
                          null));
                }
              });
        });
  }

  @Override
  public void clearShortcutItems() {
    if (!isVersionAllowed()) {
      return;
    }
    ShortcutManagerCompat.removeAllDynamicShortcuts(context);
  }

  @Override
  public @Nullable String getLaunchAction() {
    if (!isVersionAllowed()) {
      return null;
    }
    if (activity == null) {
      throw new FlutterError(
          "quick_action_getlaunchaction_no_activity",
          "There is no activity available when launching action",
          null);
    }
    final Intent intent = activity.getIntent();
    final String launchAction = intent.getStringExtra(EXTRA_ACTION);
    if (launchAction != null && !launchAction.isEmpty()) {
      ShortcutManagerCompat.reportShortcutUsed(context, launchAction);
      intent.removeExtra(EXTRA_ACTION);
    }
    return launchAction;
  }

  @TargetApi(Build.VERSION_CODES.N_MR1)
  private List<ShortcutInfoCompat> shortcutItemMessageToShortcutInfo(
      @NonNull List<ShortcutItemMessage> shortcuts) {
    final List<ShortcutInfoCompat> shortcutInfos = new ArrayList<>();

    for (ShortcutItemMessage shortcut : shortcuts) {
      final String icon = shortcut.getIcon();
      final String base64Icon = shortcut.getBase64Icon();
      final String type = shortcut.getType();
      final String title = shortcut.getLocalizedTitle();
      final ShortcutInfoCompat.Builder shortcutBuilder = new ShortcutInfoCompat.Builder(context, type);

      final Intent intent = getIntentToOpenMainActivity(type);
      System.out.println("MD2222 - Helllooooo");
      if (icon != null && !icon.isEmpty()) {
        // Load normal icon if it exists
        final int resourceId = loadResourceId(context, icon);
        if (resourceId > 0) {
          shortcutBuilder.setIcon(IconCompat.createWithResource(context, resourceId));
        }
      } else if (base64Icon != null && !base64Icon.isEmpty()) {
        // Load base64 image if icon is null

        byte[] decodedString = android.util.Base64.decode(base64Icon, android.util.Base64.DEFAULT);
        Bitmap bitmap = BitmapFactory.decodeByteArray(decodedString, 0, decodedString.length);
        System.out.println("MD2222 - Hellloooo 3332 2 2 2 o");
        if (bitmap != null) {
          shortcutBuilder.setIcon(IconCompat.createWithBitmap(bitmap));
        }

      }

      final ShortcutInfoCompat shortcutInfo = shortcutBuilder.setLongLabel(title).setShortLabel(title).setIntent(intent)
          .build();
      shortcutInfos.add(shortcutInfo);
    }
    return shortcutInfos;
  }

  // This method requires doing dynamic resource lookup, which is a discouraged
  // API.
  @SuppressWarnings("DiscouragedApi")
  private int loadResourceId(Context context, String icon) {
    if (icon == null) {
      return 0;
    }
    final String packageName = context.getPackageName();
    final Resources res = context.getResources();
    final int resourceId = res.getIdentifier(icon, "drawable", packageName);

    if (resourceId == 0) {
      return res.getIdentifier(icon, "mipmap", packageName);
    } else {
      return resourceId;
    }
  }

  private Intent getIntentToOpenMainActivity(String type) {
    final String packageName = context.getPackageName();

    return context
        .getPackageManager()
        .getLaunchIntentForPackage(packageName)
        .setAction(Intent.ACTION_RUN)
        .putExtra(EXTRA_ACTION, type)
        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        .addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
  }

  static class UiThreadExecutor implements Executor {
    private final Handler handler = new Handler(Looper.getMainLooper());

    @Override
    public void execute(Runnable command) {
      handler.post(command);
    }
  }
}
