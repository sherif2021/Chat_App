package app.sherif.chat

import android.annotation.SuppressLint
import android.os.Handler
import android.os.Looper

import android.util.Log
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class FirebaseService : FirebaseMessagingService() {

    val TAG = "SHERIFSOBHY"

    @SuppressLint("WrongThread")
    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        try {

            val data = remoteMessage.data

            if (data["type"] == "new") {

                val id = data["id"] as String
                val uid = data["uid"] as String
                val text = data["text"] as String
                val name = data["name"] as String
                val time = (data["time"] as String).toLong()
                val pic = data["pic"] as String
                val notificationId = (data["notificationId"] as String).toInt()

                /*Handler(Looper.getMainLooper()).post {

                    Log.d(TAG, if (MainActivity.eventSink == null) "that is true" else "that is false")
                    //println(eventSink == null)
                    eventSink?.success(
                        hashMapOf<String, Any>(
                            "id" to id,
                            "uid" to uid,
                            "text" to text,
                            "time" to time,
                        )
                    )
                }*/

                Log.d(TAG, text)

            }
        } catch (e: Exception) {
            Log.d(TAG, e.message!!)
        }
        super.onMessageReceived(remoteMessage)
    }

    override fun onNewToken(newToken: String) {
        super.onNewToken(newToken)
        Log.d(TAG, "NEW TOKEN: $newToken")
    }
}