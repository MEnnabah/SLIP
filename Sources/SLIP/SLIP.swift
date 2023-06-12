import Foundation

/**
 Utility struct to encode and decode SLIP frames.
 
 Start by creating a SLIP packet by calling `SLIP.Packet(_:)`. A packet is then used to be encoded or decoded.
*/
public struct SLIP {
    
    /**
     SLIP special character codes
     */
    public struct Byte {
        /**
         Frame End
         */
        public static let END: UInt8 = 0xC0
        /**
         Frame Escape
         */
        public static let ESC: UInt8 = 0xDB
        /**
         Transposed Frame End
         */
        public static let ESC_END: UInt8 = 0xDC
        /**
         Transposed Frame Escape
         */
        public static let ESC_ESC: UInt8 = 0xDD
        
        private init() {}
    }
    
    private init() {}
    
    /**
     A packet encapsulates a byte buffer to be `encoded` or `decoded`.
     */
    public struct Packet {
        /**
         A byte buffer
         */
        public let data: Data
        
        /**
         Whether to throw `SLIPError.protocolError` if the packet doesn't conform to the SLIP protocol.
         Default is `true`
         */
        public let ignoresProtocolError: Bool
        
        /**
         Creates a SLIP frame buffer, ready to be `encoded` or `decoded`
         */
        public init(_ data: Data, ignoresProtocolError: Bool = false) {
            self.data = data
            self.ignoresProtocolError = ignoresProtocolError
        }
        
        /**
         Removes `SLIP.Byte.END` from the boundaries of the buffer if there is any.
         */
        private func stripped() -> Data {
            // NOTE: for some reason, copying data to another var, and conditionally removing first and last bytes triggers EXC_BREAKPOINT
            // i.e. the following code crashes:
            
            // var copy = data
            // copy.removeFirst()
            // copy[0] // triggers EXC_BREAKPOINT
            
            var copy = Data([])
            for byte in data.enumerated() {
                guard byte.offset > 0 && byte.offset < data.count - 1 && byte.element != SLIP.Byte.END else {
                    continue
                }
                copy.append(byte.element)
            }
            
            return copy
        }
        
        public var isValid: Bool {
            guard !data.isEmpty else {
                return false
            }
            
            let stripped = stripped()
            
            for (index, byte) in stripped.enumerated() {
                if byte == SLIP.Byte.END {
                    return false
                }
                if byte == SLIP.Byte.ESC && index == stripped.count - 1 {
                    return false
                }
                if index + 1 < stripped.count {
                    let nextByte = stripped[index + 1]
                    if byte == SLIP.Byte.ESC && nextByte != SLIP.Byte.ESC_END && nextByte != SLIP.Byte.ESC_ESC {
                        return false
                    }
                }
            }
            
            return !(
                stripped.contains(SLIP.Byte.END) ||
                stripped.last == SLIP.Byte.ESC
            )
        }
        
        /**
         Encodes `data` into a SLIP-encoded packet.
         */
        public var encoded: Data {
            var output: Data = .init([
                SLIP.Byte.END
            ])
            
            data.forEach { byte in
                switch byte {
                case SLIP.Byte.END:
                    output.append(SLIP.Byte.ESC)
                    output.append(SLIP.Byte.ESC_END)
                case SLIP.Byte.ESC:
                    output.append(SLIP.Byte.ESC)
                    output.append(SLIP.Byte.ESC_ESC)
                default:
                    output.append(byte)
                    break
                }
            }
            
            output.append(SLIP.Byte.END)
            
            return output
        }
        
        /**
         Decodes  the data from the SLIP-encoded packet.
         */
        public var decoded: Data {
            get throws {
                if !ignoresProtocolError {
                    if !isValid {
                        throw SLIPError.protocolError
                    }
                }
                
                var output: Data = .init([])
                
                let stripped = stripped()
                var index = 0
                while index < stripped.count {
                    let byte = stripped[index]
                    guard index < stripped.count - 1 else {
                        output.append(byte)
                        index += 1
                        break
                    }
                    
                    let nextByte = stripped[index + 1]
                    if byte == SLIP.Byte.ESC && nextByte == SLIP.Byte.ESC_END {
                        output.append(SLIP.Byte.END)
                        index += 2
                    } else if byte == SLIP.Byte.ESC && nextByte == SLIP.Byte.ESC_ESC {
                        output.append(SLIP.Byte.ESC)
                        index += 2
                    } else {
                        output.append(byte)
                        index += 1
                    }
                }
                
                return output
            }
        }
    }
    
}
