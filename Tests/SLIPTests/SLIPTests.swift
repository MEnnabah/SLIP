import XCTest
@testable import SLIP

final class SLIPTest: XCTestCase {
    func testCreatesFrameWithoutModifyingInput() throws {
        let input = Data([0x45, SLIP.Byte.ESC_END, SLIP.Byte.END, SLIP.Byte.END, 0x45])
        let frame = SLIP.Packet(input)
        XCTAssertEqual(input, frame.data)
    }
    
    // MARK: -- Encoding
    func testEmptyFrameEncoding() {
        let input = Data([])
        let encoded = SLIP.Packet(input).encoded
        let expected = Data([SLIP.Byte.END, SLIP.Byte.END])
        XCTAssertEqual(encoded, expected)
    }
    
    func testSimpleFrameEncoding() {
        let input = Data([0x48, 0x65, 0x6C, 0x6C, 0x6F])
        let encoded = SLIP.Packet(input).encoded
        let expected = Data([SLIP.Byte.END] + input + [SLIP.Byte.END])
        XCTAssertEqual(encoded, expected)
    }
    
    func testSingleByteEncoding() {
        let input = Data([0x45])
        let encoded = SLIP.Packet(input).encoded
        let expected = Data([SLIP.Byte.END] + input + [SLIP.Byte.END])
        XCTAssertEqual(encoded, expected)
    }
    
    func testNullByteEncoding() {
        let input = Data([0x00])
        let encoded = SLIP.Packet(input).encoded
        let expected = Data([SLIP.Byte.END] + input + [SLIP.Byte.END])
        XCTAssertEqual(encoded, expected)
    }
    
    func testSpecialFrameEncoding0() {
        let input = Data([SLIP.Byte.END])
        let packet = Data([SLIP.Byte.ESC, SLIP.Byte.ESC_END])
        XCTAssertEqual(
            SLIP.Packet(input).encoded,
            Data([SLIP.Byte.END] + packet + [SLIP.Byte.END])
        )
    }
    
    func testSpecialFrameEncoding1() {
        let input = Data([SLIP.Byte.ESC])
        let packet = Data([SLIP.Byte.ESC, SLIP.Byte.ESC_ESC])
        XCTAssertEqual(
            SLIP.Packet(input).encoded,
            Data([SLIP.Byte.END] + packet + [SLIP.Byte.END])
        )
    }
    
    func testSpecialFrameEncoding2() {
        let input = Data([SLIP.Byte.ESC, SLIP.Byte.ESC_END])
        let packet = Data([SLIP.Byte.ESC, SLIP.Byte.ESC_ESC, SLIP.Byte.ESC_END])
        XCTAssertEqual(
            SLIP.Packet(input).encoded,
            Data([SLIP.Byte.END] + packet + [SLIP.Byte.END])
        )
    }
    
    func testSpecialFrameEncoding3() {
        let input = Data([SLIP.Byte.ESC, SLIP.Byte.ESC_ESC])
        let packet = Data([SLIP.Byte.ESC, SLIP.Byte.ESC_ESC, SLIP.Byte.ESC_ESC])
        XCTAssertEqual(
            SLIP.Packet(input).encoded,
            Data([SLIP.Byte.END] + packet + [SLIP.Byte.END])
        )
    }
    
    func testSpecialFrameEncoding4() {
        let input = Data([SLIP.Byte.ESC, SLIP.Byte.END])
        let packet = Data([SLIP.Byte.ESC, SLIP.Byte.ESC_ESC, SLIP.Byte.ESC, SLIP.Byte.ESC_END])
        XCTAssertEqual(
            SLIP.Packet(input).encoded,
            Data([SLIP.Byte.END] + packet + [SLIP.Byte.END])
        )
    }
    
    func testSpecialFrameEncoding5() {
        let input = Data([SLIP.Byte.ESC, SLIP.Byte.ESC])
        let packet = Data([SLIP.Byte.ESC, SLIP.Byte.ESC_ESC, SLIP.Byte.ESC, SLIP.Byte.ESC_ESC])
        XCTAssertEqual(
            SLIP.Packet(input).encoded,
            Data([SLIP.Byte.END] + packet + [SLIP.Byte.END])
        )
    }
    
    // MARK: -- Decoding
    
    func testEmptyFrameDecoding() throws {
        let frame = Data([SLIP.Byte.END, SLIP.Byte.END])
        let decoded = try SLIP.Packet(frame).decoded
        XCTAssertEqual(decoded, Data([]))
    }
    
    func testSimpleFrameDecoding() throws {
        let packet = Data([0x48, 0x6C, 0x6C, 0x6F])
        let frame = Data([SLIP.Byte.END] + packet + [SLIP.Byte.END])
        let decoded = try SLIP.Packet(frame).decoded
        XCTAssertEqual(decoded, packet)
    }
    
    func testSingleByteDecoding() throws {
        let packet = Data([0x45])
        let frame = Data([SLIP.Byte.END] + packet + [SLIP.Byte.END])
        let decoded = try SLIP.Packet(frame).decoded
        XCTAssertEqual(decoded, packet)
    }
    
    func testNullByteDecoding() throws {
        let packet = Data([0x00])
        let frame = Data([SLIP.Byte.END] + packet + [SLIP.Byte.END])
        let decoded = try SLIP.Packet(frame).decoded
        XCTAssertEqual(decoded, packet)
    }
    
    func testSpecialFrameDecoding0() throws {
        let packet = Data([SLIP.Byte.ESC, SLIP.Byte.ESC_ESC])
        let frame = Data([SLIP.Byte.END] + packet + [SLIP.Byte.END])
        let decoded = try SLIP.Packet(frame).decoded
        XCTAssertEqual(
            decoded,
            Data([SLIP.Byte.ESC])
        )
    }
    
    func testSpecialFrameDecoding1() throws {
        let packet = Data([SLIP.Byte.ESC, SLIP.Byte.ESC_END])
        let frame = Data([SLIP.Byte.END] + packet + [SLIP.Byte.END])
        let decoded = try SLIP.Packet(frame).decoded
        XCTAssertEqual(
            decoded,
            Data([SLIP.Byte.END])
        )
    }
    
    func testSpecialFrameDecoding2() throws {
        let packet = Data([SLIP.Byte.ESC_ESC, SLIP.Byte.ESC, SLIP.Byte.ESC_END])
        let frame = Data([SLIP.Byte.END] + packet + [SLIP.Byte.END])
        let decoded = try SLIP.Packet(frame).decoded
        XCTAssertEqual(
            decoded,
            Data([SLIP.Byte.ESC_ESC, SLIP.Byte.END])
        )
    }
    
    func testSpecialFrameDecoding3() throws {
        let packet = Data([SLIP.Byte.ESC_END, SLIP.Byte.ESC, SLIP.Byte.ESC_ESC])
        let frame = Data([SLIP.Byte.END] + packet + [SLIP.Byte.END])
        let decoded = try SLIP.Packet(frame).decoded
        XCTAssertEqual(
            decoded,
            Data([SLIP.Byte.ESC_END, SLIP.Byte.ESC])
        )
    }
    
    func testSpecialFrameDecoding4() throws {
        let packet = Data([SLIP.Byte.ESC, SLIP.Byte.ESC_ESC, SLIP.Byte.ESC, SLIP.Byte.ESC_END])
        let frame = Data([SLIP.Byte.END] + packet + [SLIP.Byte.END])
        let decoded = try SLIP.Packet(frame).decoded
        XCTAssertEqual(
            decoded,
            Data([SLIP.Byte.ESC, SLIP.Byte.END])
        )
    }
    
    func testSpecialFrameDecoding5() throws {
        let packet = Data([SLIP.Byte.ESC, SLIP.Byte.ESC_END, SLIP.Byte.ESC, SLIP.Byte.ESC_ESC])
        let frame = Data([SLIP.Byte.END] + packet + [SLIP.Byte.END])
        let decoded = try SLIP.Packet(frame).decoded
        XCTAssertEqual(
            decoded,
            Data([SLIP.Byte.END, SLIP.Byte.ESC])
        )
    }
    
    func testInvalidPacketThrowsProtocolError0() throws {
        let packet = Data([SLIP.Byte.ESC, 0x45])
        let frame = Data([SLIP.Byte.END] + packet + [SLIP.Byte.END])
        XCTAssertThrowsError(try SLIP.Packet(frame).decoded) { error in
            XCTAssertEqual(error as! SLIPError, SLIPError.protocolError)
        }
    }
    
    func testInvalidPacketThrowsProtocolError1() throws {
        let packet = Data([0x48, 0x65, 0x6C, 0x6C, 0x6F, SLIP.Byte.ESC])
        let frame = Data([SLIP.Byte.END] + packet + [SLIP.Byte.END])
        XCTAssertThrowsError(try SLIP.Packet(frame).decoded) { error in
            XCTAssertEqual(error as! SLIPError, SLIPError.protocolError)
        }
    }
    
    func testInvalidPacketThrowsProtocolError2() throws {
        let packet = Data([0x48, 0x65, SLIP.Byte.ESC, 0x6C, 0x6C, 0x6F])
        let frame = Data([SLIP.Byte.END] + packet + [SLIP.Byte.END])
        XCTAssertThrowsError(try SLIP.Packet(frame).decoded) { error in
            XCTAssertEqual(error as! SLIPError, SLIPError.protocolError)
        }
    }
    
    func testInvalidPacketDoesNotThrowProtocolError() throws {
        let packet = Data([0x48, 0x65, SLIP.Byte.ESC, 0x6C, 0x6C, 0x6F])
        let frame = Data([SLIP.Byte.END] + packet + [SLIP.Byte.END])
        XCTAssertNoThrow(try SLIP.Packet(frame, ignoresProtocolError: true).decoded)
    }

}
