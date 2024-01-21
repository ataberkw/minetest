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

package me.korata.finecraft;

import static android.content.ContentValues.TAG;

import android.app.NativeActivity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.os.Handler;
import android.text.InputType;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import androidx.core.content.FileProvider;

import com.google.android.gms.ads.AdError;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.FullScreenContentCallback;
import com.google.android.gms.ads.LoadAdError;
import com.google.android.gms.ads.interstitial.InterstitialAd;
import com.google.android.gms.ads.interstitial.InterstitialAdLoadCallback;
import com.google.firebase.analytics.FirebaseAnalytics;

import java.io.File;
import java.util.List;
import java.util.Locale;
import java.util.Objects;

// Native code finds these methods by name (see porting_android.cpp).
// This annotation prevents the minifier/Proguard from mangling them.
@Keep
@SuppressWarnings("unused")
public class GameActivity extends NativeActivity {
	static {
		System.loadLibrary("c++_shared");
		System.loadLibrary("minetest");
	}
	private FirebaseAnalytics mFirebaseAnalytics;
	private InterstitialAd mInterstitialAd;
	final Handler handler = new Handler();
	final int delay = 1000; // in ms
	final int firstAdDelay = 1000 * 60 * 30; // in ms
	boolean isFirstAdTick = true;

	private boolean isAdAboutToShow = false;
	private boolean onScreen = false;
	private int messageReturnCode = -1;
	private String messageReturnValue = "";

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		mFirebaseAnalytics = FirebaseAnalytics.getInstance(this);
		loadAd();
		handler.postDelayed(new Runnable() {
			public void run() {
				adTicker();
				handler.postDelayed(this, delay);
			}
		}, isFirstAdTick ? firstAdDelay : delay);
		getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
	}

	private void makeFullScreen() {
		this.getWindow().getDecorView().setSystemUiVisibility(
				View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION |
				View.SYSTEM_UI_FLAG_HIDE_NAVIGATION |
				View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY);
	}

	@Override
	public void onWindowFocusChanged(boolean hasFocus) {
		super.onWindowFocusChanged(hasFocus);
		if (hasFocus)
			makeFullScreen();
	}

	@Override
	protected void onPause() {
		super.onPause();
		onScreen = false;
	}
	@Override
	protected void onResume() {
		super.onResume();
		onScreen = true;
		makeFullScreen();
	}

	@Override
	public void onBackPressed() {
		// Ignore the back press so Minetest can handle it
	}

	private void adTicker(){
		Log.d(TAG, "adTicker: " + (onScreen));
		isFirstAdTick = false;
		if(isAdAboutToShow) {
			Log.i(TAG, "adTicker: skipped because ad is about to show");
			return;
		}
		if(mInterstitialAd == null) {
			Log.i(TAG, "adTicker: skipped because ad is null");
			return;
		}
		if(!Utils.shouldShowAd(this)) {
			Log.i(TAG, "adTicker: skipped because ad is not due");
			return;
		}
		startAdSequence();
	}

	//Show toast countdown
	private void startAdSequence(){
		isAdAboutToShow = true;
		Log.d(TAG, "startAdSequence: started");
		LayoutInflater inflater = getLayoutInflater();
		View layout = inflater.inflate(R.layout.countdown_toast, null);

		// Find the TextView in the custom layout
		TextView text = layout.findViewById(R.id.countdownText);

		// Create the Toast
		Toast toast = new Toast(getApplicationContext());
		toast.setDuration(Toast.LENGTH_SHORT);
		toast.setView(layout);

		new CountDownTimer(5000, 1000) { // 10 seconds countdown
			public void onTick(long millisUntilFinished) {
				if(!onScreen) {
					this.cancel();
					isAdAboutToShow = false;
					return;
				}
				text.setText("Ads helps us to keep the game free.\nAds in: " + (millisUntilFinished / 1000) + " seconds");
				toast.show();
			}

			public void onFinish() {
				if(mInterstitialAd != null && onScreen){
					text.setText("Showing up...");
					toast.show();
					mInterstitialAd.show(GameActivity.this);
				}else{
					isAdAboutToShow = false;
					this.cancel();
				}
			}
		}.start();

	}



	protected void loadAd(){
		AdRequest adRequest = new AdRequest.Builder().build();

		InterstitialAd.load(this,"ca-app-pub-2406666254945812/3758118895", adRequest,
			new InterstitialAdLoadCallback() {
				@Override
				public void onAdLoaded(@NonNull InterstitialAd interstitialAd) {
					// The mInterstitialAd reference will be null until
					// an ad is loaded.
					mInterstitialAd = interstitialAd;
					mInterstitialAd.setFullScreenContentCallback(adShowCallback(GameActivity.this));
					Log.i(TAG, "onAdLoaded");
				}

				@Override
				public void onAdFailedToLoad(@NonNull LoadAdError loadAdError) {
					// Handle the error
					Log.d(TAG, loadAdError.toString());
					mInterstitialAd = null;
					handler.postDelayed(new Runnable() {
						public void run() {
							loadAd();
						}
					}, 5000);
				}
			});
	}

	private FullScreenContentCallback adShowCallback(GameActivity context) {
		return new FullScreenContentCallback() {
			@Override
			public void onAdDismissedFullScreenContent() {
				// Called when fullscreen content is dismissed.
				isAdAboutToShow = false;
				loadAd();
				Utils.setLastAdShown(context);
				Log.d(TAG, "The ad was dismissed.");
			}

			@Override
			public void onAdFailedToShowFullScreenContent(AdError adError) {
				// Called when fullscreen content failed to show.
				Log.d(TAG, "The ad failed to show.");
			}

			@Override
			public void onAdShowedFullScreenContent() {
				// Called when fullscreen content is shown.
				// Make sure to set your reference to null so you don't
				// show it a second time.
				mInterstitialAd = null;
				Log.d(TAG, "The ad was shown.");
			}
		};
	}

	public void showDialog(String acceptButton, String hint, String current, int editType) {
		runOnUiThread(() -> showDialogUI(hint, current, editType));
	}

	private void showDialogUI(String hint, String current, int editType) {
		final AlertDialog.Builder builder = new AlertDialog.Builder(this);
		LinearLayout container = new LinearLayout(this);
		container.setOrientation(LinearLayout.VERTICAL);
		builder.setView(container);
		AlertDialog alertDialog = builder.create();
		CustomEditText editText = new CustomEditText(this, editType);
		container.addView(editText);
		editText.setMaxLines(8);
		editText.setHint(hint);
		editText.setText(current);
		if (editType == 1)
			editText.setInputType(InputType.TYPE_CLASS_TEXT |
					InputType.TYPE_TEXT_FLAG_MULTI_LINE);
		else if (editType == 3)
			editText.setInputType(InputType.TYPE_CLASS_TEXT |
					InputType.TYPE_TEXT_VARIATION_PASSWORD);
		else
			editText.setInputType(InputType.TYPE_CLASS_TEXT);
		editText.setSelection(Objects.requireNonNull(editText.getText()).length());
		final InputMethodManager imm = (InputMethodManager) getSystemService(INPUT_METHOD_SERVICE);
		editText.setOnKeyListener((view, keyCode, event) -> {
			// For multi-line, do not submit the text after pressing Enter key
			if (keyCode == KeyEvent.KEYCODE_ENTER && editType != 1) {
				imm.hideSoftInputFromWindow(editText.getWindowToken(), 0);
				messageReturnCode = 0;
				messageReturnValue = editText.getText().toString();
				alertDialog.dismiss();
				return true;
			}
			return false;
		});
		// For multi-line, add Done button since Enter key does not submit text
		if (editType == 1) {
			Button doneButton = new Button(this);
			container.addView(doneButton);
			doneButton.setText(R.string.ime_dialog_done);
			doneButton.setOnClickListener((view -> {
				imm.hideSoftInputFromWindow(editText.getWindowToken(), 0);
				messageReturnCode = 0;
				messageReturnValue = editText.getText().toString();
				alertDialog.dismiss();
			}));
		}
		alertDialog.setOnCancelListener(dialog -> {
			getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN);
			messageReturnValue = current;
			messageReturnCode = -1;
		});
		alertDialog.show();
		editText.requestFocusTryShow();
	}

	public int getDialogState() {
		return messageReturnCode;
	}

	public String getDialogValue() {
		messageReturnCode = -1;
		return messageReturnValue;
	}

	public float getDensity() {
		return getResources().getDisplayMetrics().density;
	}

	public int getDisplayHeight() {
		return getResources().getDisplayMetrics().heightPixels;
	}

	public int getDisplayWidth() {
		return getResources().getDisplayMetrics().widthPixels;
	}

	public void openURI(String uri) {
		Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(uri));
		startActivity(browserIntent);
	}

	public String getUserDataPath() {
		return Utils.getUserDataDirectory(this).getAbsolutePath();
	}

	public String getCachePath() {
		return Utils.getCacheDirectory(this).getAbsolutePath();
	}

	public void shareFile(String path) {
		File file = new File(path);
		if (!file.exists()) {
			Log.e("GameActivity", "File " + file.getAbsolutePath() + " doesn't exist");
			return;
		}

		Uri fileUri = FileProvider.getUriForFile(this, "me.korata.finecraft.fileprovider", file);

		Intent intent = new Intent(Intent.ACTION_SEND, fileUri);
		intent.setDataAndType(fileUri, getContentResolver().getType(fileUri));
		intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
		intent.putExtra(Intent.EXTRA_STREAM, fileUri);

		Intent shareIntent = Intent.createChooser(intent, null);
		startActivity(shareIntent);
	}

	public String getLanguage() {
		String langCode = Locale.getDefault().getLanguage();

		// getLanguage() still uses old language codes to preserve compatibility.
		// List of code changes in ISO 639-2:
		// https://www.loc.gov/standards/iso639-2/php/code_changes.php
		switch (langCode) {
			case "in":
				langCode = "id"; // Indonesian
				break;
			case "iw":
				langCode = "he"; // Hebrew
				break;
			case "ji":
				langCode = "yi"; // Yiddish
				break;
			case "jw":
				langCode = "jv"; // Javanese
				break;
		}

		return langCode;
	}

	public void logFirebase(String eventName, List<String> params) {
		Bundle bundle = new Bundle();
		for (int i = 0; i < params.size(); i += 2) {
			bundle.putString(params.get(i), params.get(i + 1));
		}
		mFirebaseAnalytics.logEvent(eventName, bundle);
		Log.d("Firebase", "Logged event " + eventName + " with params " + bundle.toString());
	}
}
