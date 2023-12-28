package no.nordicsemi.android.blinky.spec

import java.util.UUID

class BlinkySpec {

    companion object {
        val BLINKY_SERVICE_UUID: UUID = UUID.fromString("0000180F-0000-1000-8000-00805F9B34FB")
        val BLINKY_BUTTON_CHARACTERISTIC_UUID: UUID = UUID.fromString("00001524-1212-efde-1523-785feabcd123")
        val BLINKY_LED_CHARACTERISTIC_UUID: UUID = UUID.fromString("00002A58-0000-1000-8000-00805F9B34FB")
    }

}