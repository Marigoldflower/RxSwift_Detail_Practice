


import UIKit
import RxSwift
import RxCocoa




//⭐️ Observable의 종류

// 1. Just
// 자신을 subscribe하는 Subscriber들에게 단 한 번만 값을 보내는 Observable
// 값을 아무런 변화없이 그대로 Subscriber에게 보낸다.
// 예를 들어 [1, 2, 3]이라는 값을 보내면 Subscriber는 [1, 2, 3] 값을 그대로 받게 된다.
// "홍필" 이라는 값을 보내면 Subscriber는 "홍필" 이라는 값을 그대로 받게 된다.
// 사용방법은 다음과 같다.

var disposeBag = DisposeBag()

// Just 메소드를 통해서 아무런 변화없이 값을 그대로 Subscriber에게 보낸다.
// subscribe 메소드를 실행하면 Subscriber가 생성된다. (sink 메소드랑 똑같음)
Observable.just("Hello World").subscribe(onNext: { str in
    print(str) // Hello World
}).disposed(by: disposeBag) // disposeBag에 저장하지 않으면 Subscriber가 실행되지 않음


// 📌 Debug Operator란?
// debug Operator는 쉽게 말해서 코드의 문제점을 찾아낼 때, 디버깅을 쉽게 도와주는 Operator라고 생각하면 된다.
// debug("홍필") 이라고 적으면, 코드를 print 할 때, "홍필" 이라는 이름으로
// Observer에게 어떤 상황이 일어났는지 쉽게 확인할 수 있다.
Observable.just("안녕").debug("홍필")
    .subscribe { print($0) }
    .disposed(by: disposeBag)


// 2. From
// 배열로 된 값을 하나씩 하나씩 Subscriber에게 보내주는 Observable
// 좀 특이한 점은 배열로 된 값이 반드시 타입이 일치될 필요가 없다는 점이다.
// 사용 방법은 다음과 같다.

Observable.from(["RxSwift", "In", 4, "Hours"] as [Any]).subscribe(onNext: { str in
    print(str)
    // RxSwift
    // In
    // 4
    // Hours
}).disposed(by: disposeBag) // Observable로부터 받은 값을 disposeBag에 저장



// 3. Create ⭐️
// create() 메소드를 이용하여 Observable을 "직접 구현한다."
// 중요한 점은 create() 메소드를 이용하면 리턴 값이 항상 Disposable 이어야 한다는 것이다.
// 제네릭 파라미터를 사용하여 어떤 타입의 값을 가진 Observable인지 정해준 후
// Observable을 만들어내면 된다.


enum IHateError: Error {
    case createError
}


// 내가 직접 Subscriber에게 보낼 값을 만들어낼 수 있다!
// 중요한 점은 create() 메소드를 이용하면 리턴 값이 항상 Disposable 이어야 한다는 것이다.
Observable<String>.create { string in
    
    // Subscriber에게 보낼 값을 "홍필" "아주아주" "잘하고 있어" 로 정함
    // onNext라는 메소드를 통해서 Observable에 값을 넣어줄 수 있다.
    string.onNext("홍필")
    string.onNext("아주아주")
    string.onCompleted() // onCompleted가 실행되면 "그 이후의 어떤 값도 더 이상 실행되지 않는다."
    string.onNext("잘하고 있어")
    
    
    // 에러가 발생할 경우 미리 만들어놓은 에러 프로토콜로 처리하도록 함
    string.onError(IHateError.createError)
    
    
    // 리턴값은 반드시 Disposables 타입이어야 한다.
    return Disposables.create()
}.subscribe { string in
    print("현재 들어온 값은 \(string)")
} onError: { error in
    print("현재 들어온 에러는 \(error)")
} onCompleted: {
    print("Subscriber에 데이터 생성 & 전달 완료") // 에러가 들어오면 completed가 실행되지 않는다! ⭐️
}.disposed(by: disposeBag)



// 4. Defer
// Observable의 생성을 지연시키는 Observable
// Subscriber를 생성하기 전까지는 Observable을 생성하지 않고,
// Subscribe 이후에는 각 Subscriber(= Observer) 별로 새로운 Observable을 생성해준다.


var observableSwitch: Bool = false

let publisher = Observable<Int>.deferred {
    observableSwitch.toggle()
    
    if observableSwitch {
        return Observable.from([1,2,3])
    } else {
        return Observable.from([4,5,6])
    }
}

publisher.subscribe { event in
    switch event {
    case let .next(value):
        print(value)
    default:
        print("finished")
    }
    
    }.disposed(by: disposeBag)



publisher.subscribe { event in
    switch event {
    case let .next(value):
        print(value)
    default:
        print("finished")
    }
    
    }.disposed(by: disposeBag)





// 5. of
// 여러 개의 값을 보내는 Observable
// Just는 단 한 개의 값만 보내는 Observable이라면 of은 여러 개의 값을 보낼 수 있는 Observable이다. ⭐️
Observable.of(4, 5, 6).subscribe { number in
    print("들어온 숫자는 \(number)")
} onError: { error in
    print("에러가 발생했습니다")
} onCompleted: {
    print("생성 완료")
}.disposed(by: disposeBag)




// 6. Empty
// 아무 값도 없는 Observable을 생성하지만 정상적으로 종료시킨다.

Observable<Void>.empty().subscribe { void in
    print("무슨 값일까요? \(void)") // 아무 값도 없이 그냥 completed만 생성시킴
}.disposed(by: disposeBag)



// 7. Never
// 아무 값도 없는 Observable을 생성하고 종료시키지도 않는다.

Observable<Void>.never().subscribe { void in
    // 여기 있는 Observable이 아예 completed 구문도 나오지 않는 것을 확인할 수 있다.
    print("값이 종료가 안 됩니다 \(void)")
}.disposed(by: disposeBag)




// 8. Throw (Error)
// 아무 값도 없는 Observable을 생성하고 에러 이벤트만 발생시킨 후 종료된다.


Observable<Void>.error(IHateError.createError)
    .subscribe { print($0) }
    .disposed(by: disposeBag)



// 🤔 Hot Observable과 Cold Observable이 정확히 뭘까?
// Hot Observable
// - 생성과 동시에 이벤트를 방출하는 Observable



// Cold Observable
// - Observer가 Subscribe 되는 시점부터 이벤트를 생성하여 방출하는 Observable


// 예를 들면, 유튜브의 실시간 방송과 VOD 영화 개념으로 이해하면 좋겠다.
// 유튜브의 실시간 방송은 시청자(Observer)가 어느 시점에 방송을 청취하던 상관없이 방송이 진행되고
// 시청자(Observer)는 방송을 시청(Subscribe)하는 시점부터 방송을 볼 수 있다. 이 개념이 Hot Observable이다.

// 반면 VOD 영화는 어떤 시청자(Observer)건 시청(Subscribe)을 시작하면 "처음부터" 방송이 시작된다.
// 이 개념이 Cold Observable이다.



// ⭐️ Operator의 종류


// 1. Merge
// 단순히 여러 Observable들의 값들을 하나로 합치는 것.
// 여기서 중요한 점은 값들을 하나로 합쳐야 하므로, 여러 Observable들의 값 타입이 서로 같아야 한다. ⭐️



// 2. Zip
// "여러 Observable들"의 값들을 튜플 타입으로 묶어서 합치는 것. (여러 Observable들은 네트워크 처리를 할 때 충분히 생겨날 수 있다.) ⭐️
// 튜플 타입으로 묶는 것이기 때문에, 여러 Observable들의 값 타입이 서로 달라도 상관없다. ⭐️
// 단, Observable 내의 값의 개수가 서로 달라 묶이지 못하는 Observable 내의 값들은 아래 Stream으로 내려갈 수 없다는 단점이 존재한다. ⭐️
// 무슨 말이냐면 예를 들어, Observable1에는 4개의 값이 존재하고, Observable2에는 3개의 값이 존재한다고 하자.
// 그럼 Observable1에 값이 한 개가 남을 것이 아닌가?
// 그렇게 되면 Observable1에 남은 1개의 값은 아래 Stream으로 내려가지 못한다는 의미이다.



// 3. CombineLatest
// Zip과 비슷하게 여러 Observable 내의 값들을 하나로 합치지만,
// Observable의 남는 값이 하나도 없이 모두 내려가게끔 값을 묶어낸다.
// 어떻게 묶는가? 가장 최근에 아래 Stream으로 내려간 값과 묶어서 단 한 개의 값도 Observable 내에 남지 않게 한다.
// 이것이 바로 CombineLatest이다.


// 3.

// 4. Last
// Observable의 값이 Completed 되었을 때, Observable의 맨 마지막 값만 들어오는 Operator.
// 즉, Observable의 맨 마지막 값이 들어오는 시점이 Observable이 Completed되는 시점이라는 뜻이다.


// 5. Scan
// Observable에서 내려주는 값을 일단 받아서 저장한 뒤, 그 이후에 Observable에서 또 다른 값이 내려오면
// 그 전에 받은 값과 특정 연산 (+, -, *, / 등) 을 한 결과값을 저장한다.
// 그 이후에 Observable에서 또 다른 값이 내려오면 그 전에 연산을 한 결과값과 또 연산을 하여 결과값을 저장한다.
// 이것이 바로 Scan Operator이다.

let scanObservable = Observable.just(100)


// 초기값을 0으로 지정하고 추후 Observable로부터 내려오는 값을 + 연산자로 연산한다.
// 처음에 100이 들어오므로 초기값 0 + Observable 100 = 100이 나와서 100이 지정된다.
// 추후에 또 Observable로부터 100이 내려오면 이미 지정된 100과 Observable 100이 더해져 200이 지정된다.
// 추후에 또 Observable로부터 100이 내려오면 이미 지정된 200과 Observable 100이 더해져 300이 지정된다.
// 이것이 바로 Scan Operator이다.
scanObservable.scan(0, accumulator: +)
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)




// ⭐️ Scheduler의 종류

// 1. subscribe(on:)
// "subscribe(on:)"은 맨 처음 시작 스레드를 어떤 스레드로 지정할지 정해주는 Scheduler이다. ⭐️
// 예를 들어, "subscribe(on:)" Scheduler를 통해서
// 맨 처음에 시작할 스레드를 파란색 스레드로 지정한다라고 하면
// 맨 처음에 시작할 스레드는 언제나 파란색 스레드로 지정된다. ⭐️
// 즉, "subscribe(on:)"은 맨 처음 어떤 스레드에서 시작할지를 지정해주는 Scheduler이다.


//Observable.just("하나둘셋") // 2. 맨 처음 시작부터 ConcurrentDispatchQueue에서 동작하게 된다.
//    .map{ $0.count }
//    .map { [$0] }
//    // 1. subscribe(on:) 을 이곳에서 지정하면
//    .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
//    .observe(on: MainScheduler.instance)
//    .subscribe { intArray in
//        print(intArray)
//    }




// 2. observeOn:
// "observe(on:)"은 Observable의 Thread 위치를 바꿔주는 Scheduler이다. ⭐️
// 예를 들어, 파란색 스레드에서 동작하던 Observable이
// "observe(on:)" Scheduler를 만나 주황색 스레드에서 동작하도록 만들었다면
// 다음 Observable부터는 계속해서 주황색 스레드에서 동작하게 된다. ⭐️
// 다른 색깔의 스레드로 변환시켜주는 "observe(on:)" Scheduler를 만나기 전까지는 말이다.


//Observable.just("하나둘셋")
//    .map{ $0.count }
//    .map { [$0] }
//    .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
//    // observe(on:)을 여기에서 지정하면 이 아래 이후 Stream 부터는 MainScheduler에서 동작하게 된다.
//    .observe(on: MainScheduler.instance)
//    .subscribe { intArray in
//        print(intArray)
//    }




// ⭐️ Subject의 종류
// Subject의 종류를 알아내기 전에 먼저 Subject란 무엇일까?
// Subject를 정확히 알기 위해서는 우선 Observable과 Subject의 차이에 대해서 알아야 한다.
// 예시를 들어보겠다.


// Observable을 통해서 Observable 생성
let randomNumGenerator1 = Observable<Int>.create{ observer in
        observer.onNext(Int.random(in: 0 ..< 100))
        return Disposables.create()
    }

    randomNumGenerator1.subscribe(onNext: { (element) in
        print("observer 1 : \(element)")
    })
    randomNumGenerator1.subscribe(onNext: { (element) in
        print("observer 2 : \(element)")
    })


// 자 이 결과값을 보면 각각 다른 숫자가 출력된다.
// 그 이유는 Observer(= Subscriber)가 해당 Observable에 대해 독자적인 실행을 갖기 때문에 ⭐️
// 동일한 Observable 구독을 통해 생성된 두개의 Observer라고 해도
// Observable이 각각 실행되면서 Observer에게 서로 다른 값이 가는 것이다.


// 반면에 Subject는 어떨까?
// Subject는 하나의 Observable 실행이 여러 Observer(= Subscriber)에게 공유되는 것을 뜻한다. ⭐️


// Subject를 통해서 Observable 생성
let randomNumGenerator2 = BehaviorSubject(value: 0)
    randomNumGenerator2.onNext(Int.random(in: 0..<100))

    randomNumGenerator2.subscribe(onNext: { (element) in
        print("observer subject 1 : \(element)")
    })
    randomNumGenerator2.subscribe(onNext: { (element) in
        print("observer subject 2 : \(element)")
    })

// 똑같은 값이 두 Observer에게 가는 것을 확인할 수 있다. ⭐️



// 즉, 정리하자면
// Observable에서 Subscribe를 하면 항상 새로운 결과값을 전달
// (Observable의 create 코드는 항상 새롭게 실행된 결과)
// Subject에서 Subscribe를 하면 Subject에서 내려주는 값을 "모든 Observer가 공유" ⭐️

// 또한 Observable과 Subject의 차이는
// Observable은 이미 보내질 값을 위에서 아래 Stream으로 보내는 반면
// Subject는 중간에 보낼 값을 외부에서 주입시킬 수 있다는 점이다.


// 따라서 Subject와 Observable의 용도는
// Observable: 하나의 Observer에 대한 간단한 Observable이 필요할 때

// Subject:
// 1) 자주 데이터를 저장하고 수정할 때
// 2) 여러 개의 Observer가 데이터를 관찰해야 할 때 (약간 싱글톤 패턴같이) ⭐️
// 3) Observable과 Observer의 프록시 역할 (Subject는 Observable, Observer 둘 다 될 수 있음) ⭐️
// 4) 즉, 결론적으로 "UI를 실시간으로 업데이트 해줘야 할 때" (ex. 네트워크 비동기 처리) 자주 쓰이게 된다. ⭐️⭐️⭐️



enum SubjectError: Error {
    case asyncError
    case behaviorError
    case publishError
    
}


// 1. PublishSubject ⭐️⭐️
// "Subscriber가 구독을 한 이후부터 값을 보내주는 Subject". 초기값을 설정하지 않는다.
// PublishSubject를 구독한 Subscriber는 PublishSubject가 내려주는 모든 값을 다 받는다.


// PublishSubject를 사용할 때 주의할 점은 "PublishSubject를 구독한 이후부터"
// PublishSubject가 보내는 값을 받을 수 있다는 점이다. ⭐️
// 1) 먼저 PublishSubject를 구독한 이후에
// 2) PublishSubject가 onNext를 통해 보내는 값을 받을 수 있다.


let publishSubject = PublishSubject<String>()
publishSubject.onNext("지금 듣고 있음?")
publishSubject.onNext("듣고 있는거 맞지?")
publishSubject.onNext("대답 좀..")
// Subscriber가 구독하기 전에 먼저 publishSubject가 onNext를 통해 값을 보냈다.
// Subscriber가 PublishSubject를 구독하기 전이므로
// 당연히 "지금 듣고 있음?", "듣고 있는거 맞지?", "대답 좀.."이라는 값은 Subscriber가 받지 못한다. ⭐️⭐️


// PublishSubject를 구독한 이후에야
let subscriptionOne: () = publishSubject
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)


// 비로소 PublishSubject가 주는 값을 받을 수 있게 된다. ⭐️
publishSubject.onNext("이제는 값이 들어왔겠지??")
publishSubject.onNext("니트")

publishSubject.onCompleted()  // Completed 되기 전까지의 모든 값을 다 받는다.





publishSubject.onNext("반팔")
publishSubject.onNext("조거팬츠")
// 에러가 발생하면 에러가 발생하기 전까지의 값만 내보낸다.
// AsyncSubject는 에러가 발생하면 모든 값을 다 내보내지 않지만
// PublishSubject는 에러가 발생하기 전까지의 값들만 내보낸다. BehaviorSubject와 똑같다. ⭐️
publishSubject.onError(SubjectError.publishError)



print("---------------------------------------------------")




// 2. BehaviorSubject ⭐️⭐️
// 우선 BehaviorSubject는 초기값이 존재한다. 맨 처음 들어갈 값을 우선 정해줘야 한다.
// PublishSubject와 약간 다른 점은 PublishSubject는 Subscriber가 "구독을 한 이후부터",
// PublishSubject가 보내는 값을 받을 수 있는 반면,
// BehaviorSubject는 BehaviorSubject를 구독한 이후
// BehaviorSubject가 "맨 마지막에 보낸 값을 추가로 같이 받게 된다는 점"이다. ⭐️

// 이해가 안 갈 것이므로 예시를 들어보자.


let behviorSubject = BehaviorSubject(value: "피자")

behviorSubject.onNext("치킨")
behviorSubject.onNext("햄버거") // BehaviorSubject를 구독하기 전 BehaviorSubject가 맨 마지막으로 보낸 값은 "햄버거"이다. ⭐️



var firstSubscriber: () = behviorSubject
    .subscribe(onNext: { print("첫번째 구독자: \($0)") })
    .disposed(by: disposeBag)

var secondSubscriber: () = behviorSubject
    .subscribe(onNext: { print("두번째 구독자: \($0)") })
    .disposed(by: disposeBag)




behviorSubject.onNext("감자튀김") // BehaviorSubject를 구독한 이후 BehaviorSubject가 맨 마지막에 보낸 값을 추가로 같이 받게 된다.
// 즉, "햄버거"와 "감자튀김" 값을 둘 다 받게 된다.

// 에러가 발생하면 에러가 발생하기 전까지의 값들만 내보낸다.
// AsyncSubject는 에러가 발생하면 모든 값을 다 내보내지 않지만
// BehaviorSubject는 에러가 발생하기 전까지의 값들만 내보낸다. ⭐️
behviorSubject.onError(SubjectError.behaviorError)
behviorSubject.onNext("파스타")


print("---------------------------------------------------------------")



// 3. AsyncSubject
// Complete 될 때까지 이벤트는 발생하지 않으며,
// "Complete가 되면" AsyncSubject 내의 "마지막 데이터"를 실행하고 종료한다.



let asyncSubject = AsyncSubject<String>()

asyncSubject.onNext("40")
asyncSubject.onNext("50")


// asyncSubject를 구독
asyncSubject
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)


// 만일 AsyncSubject를 구독하자마자 끝내면 AsyncSubject를 구독하기 전 가장 마지막 값인 "50"을 도출하고 종료한다. ⭐️
asyncSubject.onCompleted()


// 하지만 AsyncSubject를 구독한 이후에 다른 값을 추가로 보내면, 추가로 보낸 값 중 가장 마지막 값인 "3"을 도출하고 종료한다. ⭐️
asyncSubject.onNext("1") // 외부에서 "1" 이라는 값을 할당해줌
asyncSubject.onNext("2") // 외부에서 "2" 이라는 값을 할당해줌
asyncSubject.onNext("3") // 외부에서 "3" 이라는 값을 할당해줌
asyncSubject.onCompleted() // 외부에서 completed 이라는 값을 할당해줌
asyncSubject.onNext("4") // Completed된 이후로는 Subject에 값을 보내도 값이 도출되지 않는다.


// "1", "2", "3" 중 "3" 이라는 값만 실행하고 completed 되는 것을 확인할 수 있다.





print("---------------------------------------------------")




// 4. ReplaySubject
// ReplaySubject는 create(bufferSize:) 메소드를 통해 생성할 수 있다.
// 만약 버퍼의 크기가 0이라면 PublishSubject와 동일한 역할을 한다. ⭐️
// ReplaySubject는 버퍼의 크기만큼만 딱 아래 Stream으로 내려보낸다는 특징이 있다.
// 예를 들어, 버퍼의 크기가 3이면 딱 3개의 값만 아래 Stream으로 보낸다는 의미이다.
// 버퍼의 크기가 1이면 딱 1개의 값만 아래 Stream으로 보낸다는 의미이다.

// ReplaySubject는 Subscriber가 구독을 하기 전에 받을 값을 몇 개로 지정할지 버퍼 크기로 정할 수 있다.
// 그 뒤 Subscriber가 RelaySubject를 구독하면 버퍼로 지정해놓은 값을 먼저 받고 그 이후에 값을 추가로 받는다. ⭐️


// 데이터를 2개까지만 보내도록 버퍼의 크기를 정해놓았다.
let replaySubject = ReplaySubject<String>.create(bufferSize: 2)

replaySubject.onNext("1")
// 이제 Subscriber가 ReplaySubject를 구독하면 "2", "3" 2개의 값이 내려가게 된다.
replaySubject.onNext("2")
replaySubject.onNext("3")

replaySubject
    .subscribe(onNext: { print("첫번째 구독자 \($0)") })
        
replaySubject
    .subscribe(onNext: { print("두번째 구독자 \($0)") })
    .disposed(by: disposeBag)
    

// 결과적으로 버퍼로 지정된 값을 먼저 받은 후,
// 그 뒤에 Subscriber가 구독한 후, ReplaySubject가 보낸 값인 "4"를 받게 된다. ⭐️
replaySubject.onNext("4")




