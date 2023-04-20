//
//  Mockable.swift
//  MockingKit
//
//  Created by Daniel Saidi on 2019-11-25.
//  Copyright © 2019 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This protocol can be implemented by any type that should be
 used as a mock, e.g. when unit testing.
 
 To implement the protocol, just provide a ``mock`` property:
 
 ```
 class MyMock: Mockable {
 
     let mock = Mock()
 }
 ```
 
 You can then use it to register function results, call mock
 functions (which are recorded) and inspect function calls.
 
 Only implement the protocol when you can't inherit ``Mock``,
 e.g. when mocking structs or when a mock class must inherit
 a base class, e.g. when mocking classes like `UserDefaults`.
*/
public protocol Mockable {
    
    typealias Function = Any
    
    var mock: Mock { get }
}


// MARK: - Internal Functions

extension Mockable {

    func registerCall<Arguments, Result>(
        _ call: MockCall<Arguments, Result>,
        for ref: MockReference<Arguments, Result>
    ) {
        mock.dispatchSemaphore.wait()
        let calls = mock.registeredCalls[ref.id] ?? []
        mock.registeredCalls[ref.id] = calls + [call]
        mock.dispatchSemaphore.signal()
    }

    func registerCall<Arguments, Result>(
        _ call: MockCall<Arguments, Result>,
        for ref: AsyncMockReference<Arguments, Result>
    ) {
        mock.dispatchSemaphore.wait()
        let calls = mock.registeredCalls[ref.id] ?? []
        mock.registeredCalls[ref.id] = calls + [call]
        mock.dispatchSemaphore.signal()
    }
    
    func registeredCalls<Arguments, Result>(
        for ref: MockReference<Arguments, Result>
    ) -> [MockCall<Arguments, Result>] {
        mock.dispatchSemaphore.wait()
        let calls = mock.registeredCalls[ref.id]
        mock.dispatchSemaphore.signal()
        return (calls as? [MockCall<Arguments, Result>]) ?? []
    }

    func registeredCalls<Arguments, Result>(
        for ref: AsyncMockReference<Arguments, Result>
    ) -> [MockCall<Arguments, Result>] {
        mock.dispatchSemaphore.wait()
        let calls = mock.registeredCalls[ref.id]
        mock.dispatchSemaphore.signal()
        return (calls as? [MockCall<Arguments, Result>]) ?? []
    }

    func registeredResult<Arguments, Result>(
        for ref: MockReference<Arguments, Result>
    ) -> ((Arguments) throws -> Result)? {
        mock.dispatchSemaphore.wait()
        let result = mock.registeredResults[ref.id] as? (Arguments) throws -> Result
        mock.dispatchSemaphore.signal()
        return result
    }

    func registeredResult<Arguments, Result>(
        for ref: AsyncMockReference<Arguments, Result>
    ) -> ((Arguments) async throws -> Result)? {
        mock.dispatchSemaphore.wait()
        let result = mock.registeredResults[ref.id] as? (Arguments) async throws -> Result
        mock.dispatchSemaphore.signal()
        return result
    }
}
