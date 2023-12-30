package no.nordicsemi.android.blinky.spec

import java.util.UUID

class BlinkySpec {

    companion object {
        val BLINKY_SERVICE_UUID: UUID = UUID.fromString("0000180A-0000-1000-8000-00805F9B34FB")
        val BLINKY_LED_CHARACTERISTIC_UUID: UUID = UUID.fromString("00002A57-0000-1000-8000-00805F9B34FB")
    }

}