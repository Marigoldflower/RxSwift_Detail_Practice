


import UIKit
import RxSwift
import RxCocoa
import RxRelay


// RxRelay란?
// RxCocoa 내부에 import 되어있는 라이브러리.
// Relay란 ubject의 Wrapper class이며, UI작업을 처리할 때 사용되는 Subject이다.

// 보통 Subject는 에러가 내부에서 발생하면 onError를 내뱉고 Stream이 끊어지게 되지만
// Relay는 절대로 종료되지 않고 계속 값을 내보낸다. (onError, onCompleted 같은 개념이 아예 없음) ⭐️
// 즉, 값이 dispose 되지 전까지는 계속 동작하기 때문에 UI 작업에서 사용하기 용이하다.


// Relay에는 onError, onCompleted가 존재하지 않으며 (계속 값을 방출한다는 뜻이다) ⭐️
// onNext 대신 그와 비슷한 accept() 라는 메소드를 사용한다. ⭐️
// 값이 계속 방출하는 것을 막으려먼 dispose() 메소드를 사용해야 한다.



// 추가적으로 AsyncRelay같은 개념은 없다. ⭐️
// Relay에는 오직 PublishRelay, BehaviorRelay, ReplayRelay만 존재한다.
// AsyncRelay는 그 뜻을 해석하면 "Complete 될 때", 마지막 데이터를 실행하고 종료되는 개념이므로
// onError, onCompleted라는 것 자체가 없는 Relay에는 앞뒤가 맞지 않는 개념이다.





let disposeBag = DisposeBag()


// 1. PublishRelay ⭐️⭐️
// "Subscriber가 구독을 한 이후부터 값을 보내주는 Relay". 초기값을 설정하지 않는다.


// PublishRelay를 사용할 때 주의할 점은 "PublishRelay를 구독한 이후부터"
// PublishRelay가 보내는 값을 받을 수 있다는 점이다. ⭐️
// 1) 먼저 PublishRelay를 구독한 이후에
// 2) PublishRelay가 accept()라는 메소드를 통하여 값을 보낼 때에 값을 비로소 받을 수 있다.


let publishRelay = PublishRelay<String>()

publishRelay.accept("밥")
publishRelay.accept("김치")

// Subscriber가 구독하기 전에 먼저 PublishRelay가 onNext를 통해 값을 보냈다.
// Subscriber가 PublishRelay를 구독하기 전이므로
// 당연히 "밥", "김치" 라는 값은 Subscriber가 받지 못한다. ⭐️⭐️


// Subscriber가 PublishRelay를 구독한 이후부터
let publishSubcriber: () = publishRelay
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)


// 비로소 PublishRelay가 주는 값을 받을 수 있게 된다.
publishRelay.accept("된장국")




print("---------------------------------------------------")




// 2. BehaviorRelay ⭐️⭐️
// 우선 BehaviorRelay는 초기값이 존재한다. 맨 처음 들어갈 값을 우선 정해줘야 한다.
// PublishRelay와 약간 다른 점은 PublishRelay는 Subscriber가 "구독을 한 이후부터",
// PublishRelay가 보내는 값을 받을 수 있는 반면,
// BehaviorRelay는 BehaviorRelay를 구독한 이후
// BehaviorRelay가 "맨 마지막에 보낸 값을 추가로 같이 받게 된다는 점"이다. ⭐️

// 이해가 안 갈 것이므로 예시를 들어보자.




let behviorRelay = BehaviorRelay(value: "피자")

behviorRelay.accept("치킨") // "치킨"은 맨 마지막 값이 아니므로 Subscriber가 받지 못한다.
behviorRelay.accept("햄버거") // BehaviorRelay를 구독하기 전 BehaviorRelay가 맨 마지막으로 보낸 값은 "햄버거"이다. ⭐️



var firstSubscriber: () = behviorRelay
    .subscribe(onNext: { print("첫번째 구독자: \($0)") })
    .disposed(by: disposeBag)

var secondSubscriber: () = behviorRelay
    .subscribe(onNext: { print("두번째 구독자: \($0)") })
    .disposed(by: disposeBag)




behviorRelay.accept("감자튀김") // BehaviorSubject를 구독한 이후 BehaviorSubject가 맨 마지막에 보낸 값을 추가로 같이 받게 된다.
// 즉, "햄버거"와 "감자튀김" 값을 둘 다 받게 된다.




print("---------------------------------------------------")




// 3. ReplayRelay
// ReplayRelay는 create(bufferSize:) 메소드를 통해 생성할 수 있다.
// 만약 버퍼의 크기가 0이라면 PublishRelay와 동일한 역할을 한다. ⭐️
// ReplayRelay는 버퍼의 크기만큼만 딱 아래 Stream으로 내려보낸다는 특징이 있다.
// 예를 들어, 버퍼의 크기가 3이면 딱 3개의 값만 아래 Stream으로 보낸다는 의미이다.
// 버퍼의 크기가 1이면 딱 1개의 값만 아래 Stream으로 보낸다는 의미이다.

// ReplayRelay는 Subscriber가 구독을 하기 전에 받을 값을 몇 개로 지정할지 버퍼 크기로 정할 수 있다.
// 그 뒤 Subscriber가 ReplayRelay를 구독하면 버퍼로 지정해놓은 값을 먼저 받고 그 이후에 값을 추가로 받는다. ⭐️


// 데이터를 2개까지만 보내도록 버퍼의 크기를 정해놓았다.
let replayRelay = ReplayRelay<String>.create(bufferSize: 2)

replayRelay.accept("1")
// 이제 Subscriber가 ReplaySubject를 구독하면 "2", "3" 2개의 값이 내려가게 된다.
replayRelay.accept("2")
replayRelay.accept("3")

replayRelay
    .subscribe(onNext: { print("첫번째 구독자 \($0)") })
    .disposed(by: disposeBag)
        
replayRelay
    .subscribe(onNext: { print("두번째 구독자 \($0)") })
    .disposed(by: disposeBag)
    

// 결과적으로 버퍼로 지정된 값을 먼저 받은 후,
// 그 뒤에 Subscriber가 구독한 후, ReplayRelay가 보낸 값인 "4"를 받게 된다. ⭐️
replayRelay.accept("4")





