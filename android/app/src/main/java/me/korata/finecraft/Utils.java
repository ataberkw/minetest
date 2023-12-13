package me.korata.finecraft;

import android.content.Context;
import android.content.SharedPreferences;
import android.util.Log;

import androidx.annotation.NonNull;
import java.io.File;
import java.util.Objects;

public class Utils {
	static int adShowInterval = 60 * 15; //in seconds
	@NonNull
	public static File createDirs(@NonNull File root, @NonNull String dir) {
		File f = new File(root, dir);
		if (!f.isDirectory())
			if (!f.mkdirs())
				Log.e("Utils", "Directory " + dir + " cannot be created");

		return f;
	}

	@NonNull
	public static File getUserDataDirectory(@NonNull Context context) {
		File extDir = Objects.requireNonNull(
			context.getExternalFilesDir(null),
			"Cannot get external file directory"
		);
		return createDirs(extDir, "Minetest");
	}

	@NonNull
	public static File getCacheDirectory(@NonNull Context context) {
		return Objects.requireNonNull(
			context.getCacheDir(),
			"Cannot get cache directory"
		);
	}

	public static boolean isInstallValid(@NonNull Context context) {
		File userDataDirectory = getUserDataDirectory(context);
		return userDataDirectory.isDirectory() &&
			new File(userDataDirectory, "games").isDirectory() &&
			new File(userDataDirectory, "builtin").isDirectory() &&
			new File(userDataDirectory, "client").isDirectory() &&
			new File(userDataDirectory, "textures").isDirectory();
	}

	//shared preferences last ad shown
	public static boolean shouldShowAd(@NonNull Context context) {
		SharedPreferences sharedPreferences = context.getSharedPreferences("MinetestSettings", Context.MODE_PRIVATE);
		int lastAdShown = sharedPreferences.getInt("lastAdShown", 0);
		int currentAdShown = (int) (System.currentTimeMillis() / 1000L);
		if (currentAdShown - lastAdShown > adShowInterval) {
			return true;
		} else {
			Log.d("Utils", "Ad not shown, ad will be shown in " + (adShowInterval - (currentAdShown - lastAdShown)) + " seconds");
			return false;
		}
	}

	public static void setLastAdShown(@NonNull Context context) {
		SharedPreferences sharedPreferences = context.getSharedPreferences("MinetestSettings", Context.MODE_PRIVATE);
		int currentAdShown = (int) (System.currentTimeMillis() / 1000L);
		SharedPreferences.Editor editor = sharedPreferences.edit();
		editor.putInt("lastAdShown", currentAdShown);
		editor.apply();
	}
}
