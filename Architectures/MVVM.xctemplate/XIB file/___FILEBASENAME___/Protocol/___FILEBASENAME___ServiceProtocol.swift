//___FILEHEADER___

import Foundation
import Combine

protocol ___FILEBASENAMEASIDENTIFIER___ {
    func add___VARIABLE_productName:identifier___(model: ___VARIABLE_productName:identifier___) -> AnyPublisher<Void, Error>
    func delete___VARIABLE_productName:identifier___(model: ___VARIABLE_productName:identifier___) -> AnyPublisher<Void, Error>
    func get___VARIABLE_productName:identifier___() -> AnyPublisher<[___VARIABLE_productName:identifier___], Error>
    func update___VARIABLE_productName:identifier___(model: ___VARIABLE_productName:identifier___) -> AnyPublisher<Void, Error>
}
