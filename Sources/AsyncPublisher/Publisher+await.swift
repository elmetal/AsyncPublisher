//
//  Publisher+await.swift
//  
//  
//  Created by elmetal on 2021/07/16
//  
//

import Foundation
import Combine

public extension Publisher {
    /// Awaits the element published by the upstream publisher until the specified time interval.
    /// Available when `Failure` is `URLError`.
    ///
    /// - Parameters:
    ///   - timeout: The timeout  interval of the element published by the upstream publisher.
    func `await`(timeout: DispatchTime = .distantFuture) -> AsyncPublisher<Self.Output, Self.Failure> where Failure == URLError {
        var output: Output?
        var error: Failure?
        var cancellables = Set<AnyCancellable>()

        let semaphore = DispatchSemaphore(value: 0)

        self.sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                ()
            case .failure(let e):
                error = e
            }
            semaphore.signal()
        }, receiveValue: { output = $0 })
            .store(in: &cancellables)

        _ = semaphore.wait(timeout: timeout)

        guard let result = output else {
            if let error = error {
                return AsyncPublisher(body: { (yield: Yield<Output, Failure>) in
                    yield(error)
                })
            } else {
                return AsyncPublisher(body: { (yield: Yield<Output, Failure>) in
                    yield(URLError(.timedOut))
                })
            }
        }

        return AsyncPublisher(body: { (yield: Yield<Output, Failure>) in
            yield(result)
        })
    }
}
