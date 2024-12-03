/*
Minetest
Copyright (C) 2014-2020 MoNTE48, Maksim Gamarnik <MoNTE48@mail.ua>
Copyright (C) 2014-2020 ubulem,  Bektur Mambetov <berkut87@gmail.com>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation; either version 2.1 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/

package com.mcpeturk.dilsecici;

import android.app.IntentService;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.StringRes;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.ByteBuffer;
import java.util.Collections;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;
import java.util.zip.ZipInputStream;

public class UnzipService extends IntentService {
	public static final String ACTION_UPDATE = "com.mcpeturk.dilsecici.UPDATE";
	public static final String ACTION_PROGRESS = "com.mcpeturk.dilsecici.PROGRESS";
	public static final String ACTION_PROGRESS_MESSAGE = "com.mcpeturk.dilsecici.PROGRESS_MESSAGE";
	public static final String ACTION_FAILURE = "com.mcpeturk.dilsecici.FAILURE";
	public static final int SUCCESS = -1;
	public static final int FAILURE = -2;
	public static final int INDETERMINATE = -3;
	private final int id = 1;
	private NotificationManager mNotifyManager;
	private boolean isSuccess = true;
	private String failureMessage;
	private static final int BUFFER_SIZE = 16384;
	private ByteBuffer bufferPool = ByteBuffer.allocateDirect(BUFFER_SIZE);


	private static boolean isRunning = false;
	public static synchronized boolean getIsRunning() {
		return isRunning;
	}
	private static synchronized void setIsRunning(boolean v) {
		isRunning = v;
	}

	public UnzipService() {
		super("com.mcpeturk.dilsecici.UnzipService");
	}

	@Override
	protected void onHandleIntent(Intent intent) {
		Notification.Builder notificationBuilder = createNotification();
		final File zipFile = new File(getCacheDir(), "Minetest.zip");
		try {
			setIsRunning(true);
			File userDataDirectory = Utils.getUserDataDirectory(this);

			try (InputStream in = this.getAssets().open(zipFile.getName())) {
				try (OutputStream out = new FileOutputStream(zipFile)) {
					int readLen;
					byte[] readBuffer = new byte[16384];
					while ((readLen = in.read(readBuffer)) != -1) {
						out.write(readBuffer, 0, readLen);
					}
				}
			}

			unzip(notificationBuilder, zipFile, userDataDirectory);
		} catch (IOException e) {
			isSuccess = false;
			failureMessage = e.getLocalizedMessage();
		} finally {
			setIsRunning(false);
			if (!zipFile.delete()) {
				Log.w("UnzipService", "Minetest installation ZIP cannot be deleted");
			}
		}
	}

	private Notification.Builder createNotification() {
		String name = "com.mcpeturk.dilsecici";
		String channelId = "Minetest channel";
		String description = "notifications from Minetest";
		Notification.Builder builder;
		if (mNotifyManager == null)
			mNotifyManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
			int importance = NotificationManager.IMPORTANCE_LOW;
			NotificationChannel mChannel = null;
			if (mNotifyManager != null)
				mChannel = mNotifyManager.getNotificationChannel(channelId);
			if (mChannel == null) {
				mChannel = new NotificationChannel(channelId, name, importance);
				mChannel.setDescription(description);
				// Configure the notification channel, NO SOUND
				mChannel.setSound(null, null);
				mChannel.enableLights(false);
				mChannel.enableVibration(false);
				mNotifyManager.createNotificationChannel(mChannel);
			}
			builder = new Notification.Builder(this, channelId);
		} else {
			builder = new Notification.Builder(this);
		}

		Intent notificationIntent = new Intent(this, MainActivity.class);
		notificationIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP
			| Intent.FLAG_ACTIVITY_SINGLE_TOP);
		int pendingIntentFlag = 0;
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
			pendingIntentFlag = PendingIntent.FLAG_MUTABLE;
		}
		PendingIntent intent = PendingIntent.getActivity(this, 0,
			notificationIntent, pendingIntentFlag);

		builder.setContentTitle(getString(R.string.notification_title))
				.setSmallIcon(R.mipmap.ic_launcher)
				.setContentText(getString(R.string.notification_description))
				.setContentIntent(intent)
				.setOngoing(true)
				.setProgress(0, 0, true);

		mNotifyManager.notify(id, builder.build());
		return builder;
	}

	private void unzip(Notification.Builder notificationBuilder, File zipFile, File userDataDirectory) throws IOException {
		try (ZipFile zip = new ZipFile(zipFile)) {
			int size = zip.size();
			int processed = 0;
			for (ZipEntry entry : Collections.list(zip.entries())) {
				if (entry.isDirectory()) {
					Utils.createDirs(userDataDirectory, entry.getName());
				} else {
					try (InputStream is = zip.getInputStream(entry);
						 OutputStream os = new FileOutputStream(new File(userDataDirectory, entry.getName()))) {
						copyStream(is, os);
					}
				}
				processed++;
				if (processed % 10 == 0) { // Update notification every 10 files
					publishProgress(notificationBuilder, R.string.loading, 100 * processed / size);
				}
			}
		}
	}

	private void copyStream(InputStream is, OutputStream os) throws IOException {
		byte[] buffer = bufferPool.array();
		int read;
		while ((read = is.read(buffer)) != -1) {
			os.write(buffer, 0, read);
		}
	}

	void moveFileOrDir(@NonNull File src, @NonNull File dst) throws IOException {
		try {
			Process p = new ProcessBuilder("/system/bin/mv",
				src.getAbsolutePath(), dst.getAbsolutePath()).start();
			int exitCode = p.waitFor();
			if (exitCode != 0)
				throw new IOException("Move failed with exit code " + exitCode);
		} catch (InterruptedException e) {
			throw new IOException("Move operation interrupted");
		}
	}

	boolean recursivelyDeleteDirectory(@NonNull File loc) {
		try {
			Process p = new ProcessBuilder("/system/bin/rm", "-rf",
				loc.getAbsolutePath()).start();
			return p.waitFor() == 0;
		} catch (IOException | InterruptedException e) {
			return false;
		}
	}

	private void publishProgress(@Nullable  Notification.Builder notificationBuilder, @StringRes int message, int progress) {
		Intent intentUpdate = new Intent(ACTION_UPDATE);
		intentUpdate.putExtra(ACTION_PROGRESS, progress);
		intentUpdate.putExtra(ACTION_PROGRESS_MESSAGE, message);
		if (!isSuccess)
			intentUpdate.putExtra(ACTION_FAILURE, failureMessage);
		sendBroadcast(intentUpdate);

		if (notificationBuilder != null) {
			notificationBuilder.setContentText(getString(message));
			if (progress == INDETERMINATE) {
				notificationBuilder.setProgress(100, 50, true);
			} else {
				notificationBuilder.setProgress(100, progress, false);
			}
			mNotifyManager.notify(id, notificationBuilder.build());
		}
	}

	@Override
	public void onDestroy() {
		super.onDestroy();
		mNotifyManager.cancel(id);
		publishProgress(null, R.string.loading, isSuccess ? SUCCESS : FAILURE);
	}
}
