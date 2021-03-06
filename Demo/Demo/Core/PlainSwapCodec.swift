import BitcoinCore
import AtomicSwapCore

class PlainSwapCodec {
    enum PlainSwapCodecError : Error {
        case wrongRequest
        case wrongResponse
    }

    static let separator: Character = "|"

    func getString(from message: SwapRequest) -> String {
        let list: [String] = [
            message.id,
            message.initiatorCoinCode,
            message.responderCoinCode,
            String(message.rate),
            String(message.amount),
            message.secretHash.hex,
            message.initiatorRedeemPKH.hex,
            message.initiatorRefundPKH.hex
        ]

        return list.joined(separator: String(PlainSwapCodec.separator))
    }

    func getRequest(from str: String) throws -> SwapRequest {
        let parts = str.split(separator: PlainSwapCodec.separator).map { String($0) }

        guard parts.count == 8 else {
            throw PlainSwapCodecError.wrongRequest
        }

        let id = parts[0]
        let initiatorCoinCode = parts[1]
        let responderCoinCode = parts[2]

        guard let rate = Double(parts[3]), let amount = Double(parts[4]),
              let secretHash = Data(hex: parts[5]),
              let initiatorRedeemPKH = Data(hex: parts[6]), let initiatorRefundPKH = Data(hex: parts[7]) else {
            throw PlainSwapCodecError.wrongRequest
        }

        return SwapRequest(
                id: id, initiatorCoinCode: initiatorCoinCode, responderCoinCode: responderCoinCode,
                rate: rate, amount: amount, secretHash: secretHash,
                initiatorRefundPKH: initiatorRefundPKH, initiatorRedeemPKH: initiatorRedeemPKH)
    }

    func getString(from response: SwapResponse) -> String {
        let list: [String] = [
            response.id,
            String(response.initiatorTimestamp),
            String(response.responderTimestamp),
            response.responderRedeemPKH.hex,
            response.responderRefundPKH.hex
        ]

        return list.joined(separator: String(PlainSwapCodec.separator))
    }

    func getResponse(from str: String) throws -> SwapResponse {
        let parts = str.split(separator: PlainSwapCodec.separator).map { String($0) }

        guard parts.count == 5 else {
            throw PlainSwapCodecError.wrongResponse
        }

        let id = parts[0]

        guard let initiatorTimestamp = Int(parts[1]), let responderTimestamp = Int(parts[2]),
              let responderRedeemPKH = Data(hex: parts[3]), let responderRefundPKH = Data(hex: parts[4]) else {
            throw PlainSwapCodecError.wrongResponse
        }

        return SwapResponse(
                id: id, initiatorTimestamp: initiatorTimestamp, responderTimestamp: responderTimestamp,
                responderRefundPKH: responderRefundPKH, responderRedeemPKH: responderRedeemPKH
        )
    }

}
