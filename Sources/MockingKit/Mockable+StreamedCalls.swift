import Foundation

public enum StreamedCallTerminationStrategy {

    case registeredCalls(Int)
    case timeout(TimeInterval)

    public static var firstRegisteredCall: Self {
        .registeredCalls(1)
    }

    public static var defaultTimeout: Self {
        .timeout(3)
    }
}


// MARK: - Public Functions

public extension Mockable {

    /**
     Get a stream of all calls to a certain mock reference.

     - Parameters:
       - ref: The mock reference to check calls for.
       - timeout: The timout to wait until forcing  a completion
     */
    func streamedCalls<Arguments, Result>(
        to ref: MockReference<Arguments, Result>, terminationStrategy: StreamedCallTerminationStrategy = .firstRegisteredCall
    ) -> AsyncStream<MockCall<Arguments, Result>> {
        streamedRegisteredCalls(id: ref.id, terminationStrategy: terminationStrategy)
    }

    /**
     Get a stream of all calls to a certain mock reference.

     - Parameters:
       - refKeyPath: A key path to the mock reference to check calls for.
       - timeout: The timout to wait until forcing  a completion
     */
    func streamedCalls<Arguments, Result>(
        to refKeyPath: KeyPath<Self, MockReference<Arguments, Result>>, terminationStrategy: StreamedCallTerminationStrategy = .firstRegisteredCall
    ) -> AsyncStream<MockCall<Arguments, Result>> {
        streamedCalls(to: self[keyPath: refKeyPath], terminationStrategy: terminationStrategy)
    }

    /**
     Get a stream of all calls to a certain async mock reference.

     - Parameters:
       - ref: The mock reference to check calls for.
       - timeout: The timout to wait until forcing  a completion
     */
    func streamedCalls<Arguments, Result>(
        to ref: AsyncMockReference<Arguments, Result>, terminationStrategy: StreamedCallTerminationStrategy = .firstRegisteredCall
    ) -> AsyncStream<MockCall<Arguments, Result>> {
        streamedRegisteredCalls(id: ref.id, terminationStrategy: terminationStrategy)
    }

    /**
     Get a stream of all calls to a certain async mock reference.

     - Parameters:
       - refKeyPath: A key path to the mock reference to check calls for.
       - timeout: The timout to wait until forcing  a completion
     */
    func streamedCalls<Arguments, Result>(
        to refKeyPath: KeyPath<Self, AsyncMockReference<Arguments, Result>>, terminationStrategy: StreamedCallTerminationStrategy = .firstRegisteredCall
    ) -> AsyncStream<MockCall<Arguments, Result>> {
        streamedCalls(to: self[keyPath: refKeyPath], terminationStrategy: terminationStrategy)
    }
}


// MARK: - Private Functions

private extension Mockable {

    func streamedRegisteredCalls<Arguments, Result>(
        id: UUID,
        terminationStrategy: StreamedCallTerminationStrategy
    ) -> AsyncStream<MockCall<Arguments, Result>> {
        AsyncStream { continuation in
            var countedCalls = 0

            mock.onRegisterCallActions[id] = { call in
                guard let call = call as? MockCall<Arguments, Result> else { return }
                continuation.yield(call)
                countedCalls += 1

                if case .registeredCalls(let maxCalls) = terminationStrategy, countedCalls >= maxCalls {
                    continuation.finish()
                }
            }
            let registeredCalls = mock.registeredCalls[id]

            let calls = registeredCalls?.compactMap { $0 as? MockCall<Arguments, Result> } ?? []
            for call in calls {
                continuation.yield(call)
                countedCalls += 1

                if case .registeredCalls(let maxCalls) = terminationStrategy, countedCalls >= maxCalls {
                    continuation.finish()
                }
            }

            continuation.onTermination = { @Sendable _ in
                mock.onRegisterCallActions[id] = nil
            }

            if case .timeout(let timeInterval) = terminationStrategy {
                Task {
                    try await Task.sleep(nanoseconds: UInt64(timeInterval) * 1_000_000_000)
                    continuation.finish()
                }
            }
        }
    }
}
