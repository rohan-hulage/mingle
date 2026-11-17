package com.mingle.app.mingle

import android.inputmethodservice.InputMethodService
import android.os.Handler
import android.os.Looper
import android.view.Gravity
import android.view.inputmethod.EditorInfo
import android.view.View
import android.view.inputmethod.InputConnection
import android.widget.Button
import android.widget.EditText
import android.widget.LinearLayout
import android.widget.TextView
import org.json.JSONArray
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL

class MingleInputMethodService : InputMethodService() {
    private val mainHandler = Handler(Looper.getMainLooper())
    private lateinit var promptInput: EditText
    private lateinit var replyList: LinearLayout
    private lateinit var generateButton: Button
    private lateinit var feedback: TextView
    private var tone = "friendly"

    override fun onStartInputView(info: EditorInfo?, restarting: Boolean) {
        super.onStartInputView(info, restarting)
        val inputType = info?.inputType ?: 0
        val variation = inputType and android.text.InputType.TYPE_MASK_VARIATION
        val secure = variation in setOf(
            android.text.InputType.TYPE_TEXT_VARIATION_PASSWORD,
            android.text.InputType.TYPE_TEXT_VARIATION_VISIBLE_PASSWORD,
            android.text.InputType.TYPE_TEXT_VARIATION_WEB_PASSWORD,
            android.text.InputType.TYPE_NUMBER_VARIATION_PASSWORD,
        )
        if (::generateButton.isInitialized && secure) {
            promptInput.text.clear()
            replyList.removeAllViews()
            generateButton.isEnabled = false
            feedback.text = "Mingle suggestions are disabled in password fields."
        } else if (::generateButton.isInitialized) {
            generateButton.isEnabled = true
        }
    }

    override fun onCreateInputView(): View {
        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(16, 12, 16, 12)
            setBackgroundColor(0xFFF8F6FC.toInt())
        }
        val title = TextView(this).apply {
            text = "mingle  ·  your words, your way"
            textSize = 15f
            setTextColor(0xFF211A31.toInt())
            setPadding(2, 0, 0, 10)
        }
        promptInput = EditText(this).apply {
            hint = "Type the message or context to reply to"
            minLines = 1
            maxLines = 2
            textSize = 14f
            setSingleLine(false)
        }
        val toneRow = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
        }
        listOf("Friendly", "Funny", "Flirty", "Professional").forEach { label ->
            toneRow.addView(Button(this).apply {
                text = label
                textSize = 11f
                minHeight = 42
                minWidth = 0
                setPadding(2, 0, 2, 0)
                setOnClickListener {
                    tone = label.lowercase()
                    feedback.text = "Tone: $label"
                }
            }, LinearLayout.LayoutParams(0, -2, 1f))
        }
        generateButton = Button(this).apply {
            text = "Generate replies"
            setOnClickListener { generateReplies() }
        }
        feedback = TextView(this).apply {
            text = "Only the text you enter here is sent for suggestions."
            textSize = 11f
            setTextColor(0xFF706A7B.toInt())
            setPadding(0, 4, 0, 8)
        }
        replyList = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
        }
        root.addView(title)
        root.addView(promptInput)
        root.addView(toneRow)
        root.addView(generateButton)
        root.addView(feedback)
        root.addView(replyList)
        return root
    }

    private fun generateReplies() {
        val message = promptInput.text.toString().trim()
        if (message.isEmpty()) {
            feedback.text = "Type a message or context first."
            return
        }

        val button = generateButton
        button.isEnabled = false
        button.text = "Finding your words…"
        feedback.text = "Connecting to your Mingle API…"
        replyList.removeAllViews()

        Thread {
            try {
                val endpoint = URL("http://10.0.2.2:8000/api/v1/replies/generate")
                val connection = endpoint.openConnection() as HttpURLConnection
                connection.requestMethod = "POST"
                connection.connectTimeout = 8000
                connection.readTimeout = 18000
                connection.doOutput = true
                connection.setRequestProperty("Content-Type", "application/json")
                val payload = JSONObject()
                    .put("message", message)
                    .put("tone", tone)
                    .put("language", "English")
                    .put("length", "medium")
                    .put("context", "")
                connection.outputStream.use { it.write(payload.toString().toByteArray()) }
                val code = connection.responseCode
                val stream = if (code in 200..299) connection.inputStream else connection.errorStream
                val response = stream.bufferedReader().use { it.readText() }
                if (code !in 200..299) error("API returned $code")
                val replies = JSONObject(response).getJSONArray("replies")
                mainHandler.post {
                    showReplies(replies)
                    feedback.text = "Tap a reply to insert it. Review before sending."
                }
                connection.disconnect()
            } catch (_: Exception) {
                mainHandler.post {
                    feedback.text = "Could not reach the API. Open Mingle to try its offline samples."
                }
            } finally {
                mainHandler.post {
                    button.isEnabled = true
                    button.text = "Generate replies"
                }
            }
        }.start()
    }

    private fun showReplies(replies: JSONArray) {
        for (index in 0 until replies.length()) {
            val reply = replies.getJSONObject(index).getString("text")
            replyList.addView(Button(this).apply {
                text = reply
                textSize = 13f
                isAllCaps = false
                gravity = Gravity.START or Gravity.CENTER_VERTICAL
                setOnClickListener {
                    val connection: InputConnection? = currentInputConnection
                    connection?.commitText(reply, 1)
                    requestHideSelf(0)
                }
            })
        }
    }
}
