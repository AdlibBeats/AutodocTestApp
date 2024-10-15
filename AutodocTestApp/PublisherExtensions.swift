//
//  PublisherExtensions.swift
//  AutodocTestApp
//
//  Created by Andrey Vasiliev on 15.10.2024.
//

import Combine

extension Publisher {
    func flatMapLatest<T: Publisher>(_ transform: @escaping (Self.Output) -> T) -> Publishers.SwitchToLatest<T, Publishers.Map<Self, T>> where T.Failure == Self.Failure {
        map(transform).switchToLatest()
    }
}

extension Publisher where Self.Failure == Never {
    func bind<S: Subject<Output, Failure>>(to subject: S) -> AnyCancellable {
        sink { subject.send($0) }
    }
}
