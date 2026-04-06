import Foundation
import Network

final class EmailService {
    static let shared = EmailService()
    private init() {}

    private let smtpHost = "smtp.mail.ru"
    private let smtpPort: UInt16 = 465
    private let fromEmail = "areuknow_mary@mail.ru"
    private let fromPassword = "1n46Ffx8N1eGJWEsENBP"

    private func sendEmail(to email: String, subject: String, htmlBody: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
        let message = """
        From: \(fromEmail)
        To: \(email)
        Subject: \(subject)
        Content-Type: text/html; charset=UTF-8
        MIME-Version: 1.0
        
        \(htmlBody)
        """
        let queue = DispatchQueue(label: "smtp.queue")
        
        // ✅ Используем TLS параметры для защищённого соединения
        let tlsOptions = NWProtocolTLS.Options()
        let parameters = NWParameters(tls: tlsOptions)
        parameters.allowLocalEndpointReuse = true
        let port = NWEndpoint.Port(rawValue: smtpPort) ?? ""
        let connection = NWConnection(
            host: NWEndpoint.Host(smtpHost),
            port: NWEndpoint.Port(rawValue: smtpPort)!,
            using: parameters
        )

        connection.stateUpdateHandler = { state in
            switch state {
            case .ready:
                print("✅ TLS соединение установлено")
                self.sendCommand(connection, "EHLO localhost\r\n") { _ in
                    self.sendCommand(connection, "AUTH LOGIN\r\n") { _ in
                        let userBase64 = Data(self.fromEmail.utf8).base64EncodedString()
                        let passBase64 = Data(self.fromPassword.utf8).base64EncodedString()

                        self.sendCommand(connection, "\(userBase64)\r\n") { _ in
                            self.sendCommand(connection, "\(passBase64)\r\n") { _ in
                                self.sendCommand(connection, "MAIL FROM:<\(self.fromEmail)>\r\n") { _ in
                                    self.sendCommand(connection, "RCPT TO:<\(email)>\r\n") { _ in
                                        self.sendCommand(connection, "DATA\r\n") { _ in
                                            self.sendCommand(connection, "\(message)\r\n.\r\n") { _ in
                                                self.sendCommand(connection, "QUIT\r\n") { _ in
                                                    DispatchQueue.main.async {
                                                        completion(.success(()))
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            case .failed(let error):
                print("❌ Ошибка соединения: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            default:
                break
            }
        }

        connection.start(queue: queue)
    }
        
    

    
    func sendVerificationCode(to email: String, code: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let subject = "verificationCode".localized
        
        let htmlBody = """
        <div style="font-family: Arial, sans-serif; text-align: center; padding: 20px;">
            <h2 style="color: #007AFF;">ResumeHub</h2>
            <div style="font-size: 48px; font-weight: bold;">\(code)</div>
            <p>\("codeFor15min".localized)</p>
        </div>
        """
        sendEmail(to: email, subject: subject, htmlBody: htmlBody, completion: completion)

        
        
    }
    func sendCustomEmail(to email: String, newPassword: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let subject = "\("newPasswordSent".localized) ResumeHub"
        let htmlBody = """
            <div style="font-family: Arial, sans-serif; text-align: center; padding: 20px;">
                <h2 style="color: #007AFF;">ResumeHub</h2>
                <p>\("newPasswordSent".localized)</p>
                <div style="background: #f5f5f5; padding: 15px; border-radius: 10px; font-size: 24px; font-weight: bold;">
                    \(newPassword)
                </div>
                <p>\("loginAfterReset".localized)</p>
            </div>
            """
        sendEmail(to: email, subject: subject, htmlBody: htmlBody, completion: completion)
        
    }
    private func sendCommand(_ connection: NWConnection, _ command: String, completion: @escaping (Bool) -> Void) {
        print("📤 Отправка: \(command.trimmingCharacters(in: .newlines))")
        
        connection.send(content: command.data(using: .utf8), completion: .contentProcessed { error in
            if let error = error {
                print("❌ SMTP send error: \(error)")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }

            connection.receive(minimumIncompleteLength: 1, maximumLength: 1024) { data, _, _, error in
                if let error = error {
                    print("❌ Receive error: \(error)")
                    DispatchQueue.main.async {
                        completion(false)
                    }
                    return
                }
                
                if let data = data, let response = String(data: data, encoding: .utf8) {
                    print("📥 SMTP response: \(response.trimmingCharacters(in: .newlines))")
                }
                DispatchQueue.main.async {
                    completion(true)
                }
            }
        })
    }
}
