package com.example.cyber_jacket

import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import com.example.audio_reader.AudioReader
import com.example.audio_reader.AudioReaderConfiguration
import com.example.audio_reader.RecommendedSampleRateProvider
import com.mishkov.kiss_fft_jni.KISSFastFourierTransformer
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlin.math.roundToInt
import kotlin.math.sqrt

class MainActivity : FlutterActivity(), EventChannel.StreamHandler,
    MethodChannel.MethodCallHandler {
    private val uiThreadHandler: Handler = Handler(Looper.getMainLooper())
    private var uiThreadEvents: EventChannel.EventSink? = null

    private var audioReader: AudioReader? = null

    private var eventChannel: EventChannel? = null
    private var controller: MethodChannel? = null

    private val frequenciesDivisionByColumn = listOf(
        FrequencyInterval(0.0, 250.0),
        FrequencyInterval(251.0, 300.0),
        FrequencyInterval(301.0, 450.0),
        FrequencyInterval(451.0, 480.0),
        FrequencyInterval(481.0, 620.0),
        FrequencyInterval(621.0, 800.0),
        FrequencyInterval(801.0, 1200.0),
        FrequencyInterval(1201.0, 20000.0),
    )

    private val columnHeight = 8

    private var visualizerConfiguration = VisualizerConfiguration()

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        controller = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            VISUALIZER_CONTROLLER_CHANNEL_NAME,
        )
        controller!!.setMethodCallHandler(this)

        eventChannel = EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            VISUALIZER_CHANNEL_NAME
        )

        eventChannel!!.setStreamHandler(this)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        uiThreadEvents = events

        val sampleRate = RecommendedSampleRateProvider(context).get()
        val readsNumber = AudioReaderConfiguration.getMinReadsNumber(sampleRate)
        val config = AudioReaderConfiguration(sampleRate, readsNumber)

        audioReader = AudioReader(config) { data ->
            val result =
                KISSFastFourierTransformer().transformRealOptimisedForward(data.map { e -> e.toDouble() }
                    .toDoubleArray())

            val frequencyStep = config.sampleRate.toDouble() / (data.size)
            val startFrequencyInHz = 20
            val endFrequencyInHz = 16000
            val firstIndex = (startFrequencyInHz / frequencyStep).roundToInt()
            val endIndex = (endFrequencyInHz / frequencyStep).roundToInt()

            val resultData = DoubleArray(frequenciesDivisionByColumn.size)
            var columnIndex = 0
            var frequencySum = 0.0
            var frequenciesCount = 0
            for (i in firstIndex until endIndex) {
                val nextAmplitude: Double =
                    sqrt(result[i].real * result[i].real + result[i].imaginary * result[i].imaginary)

                val frequency = (config.sampleRate.toDouble() / data.size) * i
                while (frequency > frequenciesDivisionByColumn[columnIndex].end) {
                    if (frequenciesCount != 0 && columnIndex < resultData.size) {
                        resultData[columnIndex] = frequencySum / frequenciesCount
                    }

                    if ((columnIndex + 1) < frequenciesDivisionByColumn.size) {
                        columnIndex++
                    } else {
                        break
                    }
                    frequencySum = 0.0
                    frequenciesCount = 0

                }

                if (nextAmplitude > visualizerConfiguration.amplitudeThreshold) {
                    frequencySum += ((nextAmplitude / visualizerConfiguration.amplitudeLimit) * columnHeight)
                    frequenciesCount++
                }
            }

            if (frequenciesCount != 0 && columnIndex < resultData.size) {
                resultData[columnIndex] = frequencySum / frequenciesCount
            }

            try {
                uiThreadHandler.post {
                    uiThreadEvents!!.success(resultData)
                }
            } catch (e: IllegalArgumentException) {
                // TODO("Make better logging")
                println("sound_frequency_meter: " + resultData.hashCode() + " is not valid!")
                uiThreadHandler.post {
                    uiThreadEvents!!.error("-1", "Invalid Data", e)
                }
            }

        }

        audioReader?.startStream()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "updateConfig") {
            val mapArguments = call.arguments as Map<*, *>

            val amplitudeThreshold = mapArguments["amplitudeThreshold"] as Double?
            val amplitudeLimit = mapArguments["amplitudeLimit"] as Double?

            if (amplitudeThreshold != null && amplitudeLimit != null) {
                visualizerConfiguration = VisualizerConfiguration(
                    amplitudeThreshold.toDouble(),
                    amplitudeLimit.toDouble()
                )
                result.success(null)
            } else {
                result.error(
                    "NO_ARGUMENT",
                    "Cannot update visualizer config.",
                    "At least one of arguments is null:\namplitudeThreshold: $amplitudeThreshold, amplitudeLimit: $amplitudeLimit"
                )
            }
        } else if (call.method == "getConfig") {
            result.success(visualizerConfiguration.toMap())
        } else {
            result.notImplemented()
        }
    }

    override fun onCancel(arguments: Any?) {
        audioReader?.stopStream()
        audioReader?.release()
    }

    companion object {
        private const val VISUALIZER_CHANNEL_NAME = "visualizer"
        private const val VISUALIZER_CONTROLLER_CHANNEL_NAME = "visualizer_controller"
    }
}

class FrequencyInterval(val begin: Double, val end: Double)

class VisualizerConfiguration(
    val amplitudeThreshold: Double = 15000.0,
    val amplitudeLimit: Double = 25000.0
) {
    fun toMap(): Map<String, Any> {
        return mapOf(
            "amplitudeThreshold" to amplitudeThreshold,
            "amplitudeLimit" to amplitudeLimit,
        )
    }
}