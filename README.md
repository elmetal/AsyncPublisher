# AsyncPublisher
Publisher waiting for data fetching like URLSession.DataTaskPublisher.

## Usage

```swift
 URLSession.shared.dataTaskPublisher(for: URL(string: "https://example.com")!)
     .await(timeout: .now() + .seconds(10))
     .sink(receiveCompletion: { _ in },
           receiveValue: { print($0) })
     .store(in: &cancellables)
```
