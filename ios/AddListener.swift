func addListener(_ query: Query) -> AnyPublisher<[DocumentChangeType: [M]], TakeoffError> {
    return Publishers.QuerySnapshotPublisher(query)
        .flatMap { querySnapshot -> AnyPublisher<[DocumentChangeType: [M]], TakeoffError> in
            do {
                var docsByChangeType = [DocumentChangeType: [M]]()

                try querySnapshot.documentChanges.forEach { docChange in
                    if let doc = try docChange.document.data(as: M.self) {
                        if !docsByChangeType.keys.contains(docChange.type) {
                            docsByChangeType[docChange.type] = []
                        }

                        docsByChangeType[docChange.type]!.append(doc)
                    }
                }

                return Just(docsByChangeType)
                    .setFailureType(to: TakeoffError.self)
                    .eraseToAnyPublisher()
            } catch(let error) {
                return Fail(error: .default(description: error.localizedDescription))
                    .eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
}

func addListener(_ id: String) -> AnyPublisher<M?, TakeoffError> {
    let ref = db
        .collection("games")
        .document(id)

    return Publishers.DocumentSnapshotPublisher(ref: ref)
        .flatMap { docSnapshot -> AnyPublisher<M?, TakeoffError> in
            do {
                let doc = try docSnapshot.data(as: M.self)

                return Just(doc)
                    .setFailureType(to: TakeoffError.self)
                    .eraseToAnyPublisher()
            } catch(let error) {
                return Fail(error: .default(description: error.localizedDescription))
                    .eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
}