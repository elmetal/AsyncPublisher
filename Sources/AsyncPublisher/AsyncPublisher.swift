import Foundation
import Combine

public final class AsyncPublisher<O, F: Error>: Publisher {
    public typealias Output = O
    public typealias Failure = F

    private let yield = Yield<O, F>()
    private let body: (Yield<O, F>) throws -> ()

    init(body: @escaping (Yield<O, F>) throws -> ()) {
        self.body = body
    }

    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        yield.subject.subscribe(subscriber)
        subscriber.receive(subscription: Subscriptions.empty)
        do {
            try body(yield)
            yield.subject.send(completion: .finished)
        } catch {
            yield.subject.send(completion: .failure(error as! F))
        }
    }
}

final class Yield<O, F: Error> {
    let subject = PassthroughSubject<O, F>()
    private var cancellables = Set<AnyCancellable>()

    init() {}

    func callAsFunction(_ value: O) {
        subject.send(value)
    }

    func callAsFunction(_ error: F) {
        subject.send(completion: .failure(error))
    }

    func callAsFunction<P>(_ publisher: P) where P: Publisher, P.Output == O, P.Failure == F {
        publisher
            .sink(receiveCompletion: { [weak self] in
                switch $0 {
                case .finished:
                    ()
                case .failure(let error):
                    self?.subject.send(completion: .failure(error))
                }
            }, receiveValue: { [weak self] in self?.subject.send($0) })
    }
}
