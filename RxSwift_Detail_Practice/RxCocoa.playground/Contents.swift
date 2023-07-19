


import UIKit
import RxSwift
import RxCocoa
import RxRelay


let disposeBag = DisposeBag()



// RxCocoa란?
// RxCocoa는 애플 환경의 애플리케이션을 제작하기 위해 모아놓은
// Cocoa Framework를 Rx스럽게 사용하기 위해 만들어진 라이브러리이다.
// 즉, 기존에 애플에 존재하던 Cocoa Framework에
// Reactive 라이브러리의 장점을 입혀서 사용할 수 있게 한 라이브러리로
// RxSwift와 RxRelay에 의존한다.



// 1) bind(to:)
// Observable이나 Subject로부터 내려받은 값을 UI 객체와 하나로 묶어서
// Observable이나 Subject의 값이 업데이트 될 때마다, UI 객체의 값도 실시간으로 업데이트 되게끔 하는
// RxCocoa의 메소드 중 하나. 사실상 실무 작업에서 많이 쓰일 수 밖에 없는 메소드이다. ⭐️
// bind(to:) 메소드 내부에는 "실시간으로 업데이트하려는 UI객체의 이름.rx.text" 이런 방식으로 사용하면 된다.
// 만일 실시간으로 업데이트하려는 UI 객체가 UIImageView라면
// bind(to:) 메소드 내부에 "실시간으로 업데이트하려는 UI객체의 이름.rx.image" 이런 방식으로 사용하면 된다.


// 예를 들어 UI에 올려야 할 객체에 myName이 있다고 쳐보자.
let myName: UILabel = {
    let label = UILabel()
    return label
}()


let nameSubject = BehaviorSubject<String>(value: "홍필")

nameSubject
    .map { "황" + $0 }
    .observe(on: MainScheduler.instance)
    // Observable이나 Subject의 값이 변경될때마다 UI 객체의 값도 실시간으로 업데이트 되게끔 하기 위해
    // Observable이나 Subject으로부터 내려받은 값을 UI 객체와 하나로 묶었다.
    .bind(to: myName.rx.text)
    .disposed(by: disposeBag)

print(myName.text!) // myName label에 "황홍필" 이라는 값이 들어온다.



// 또는 TableView 전체에 bind(to:) 메소드를 적용할 수도 있다. 바로 이렇게 말이다. ⭐️


let tableView = UITableView()
let tableViewCell = UITableViewCell()

let items: [Int] = [1, 2, 3, 4]

// 이렇게 tableView 전체에 bind(to:) 메소드를 통해서 값을 할당하게 되면
// UITableViewDataSource 프로토콜은 아예 필요가 없어지게 된다. 쓸 필요가 없다. ⭐️⭐️
// 그냥 이 코드 구문을 viewDidLoad()에 넣어주고 실행하면 된다.
let tableViewCellObservable = BehaviorSubject(value: items)
tableViewCellObservable
    .map { "\($0)" }
    .observe(on: MainScheduler.instance)
    // items(cellIdentifier:cellType:) 메소드를 통해서
    // 테이블 뷰 셀의 identifier를 적어준 뒤에
    // 그냥 바로 배열 그 자체를 tableView에 bind 시켜주면
    // Observable이나 Subject의 값이 변경될 때, 실시간으로 UI 데이터의 값도 같이 변경된다.
    .bind(to: tableView.rx.items(cellIdentifier: "어쩌구", cellType: UITableViewCell.self)) { index, item, cell in
        
        // 이런 방식으로 클로저 내부에 각 셀에다가 Observable로부터 받은 값을 할당해주면 된다.
//        cell.number.text = item.text
        
    }
    .disposed(by: disposeBag)


    

// 2) asDriver()
// 한 번 잘 생각해보자. 우리가 Observable이나 Subject로부터 값을 받은 뒤에 UI에 데이터를 할당해줄 때에는
// 반드시 메인 스레드에서 동작해야 하기 때문에
// 아래의 Stream을 메인 스레드에서 동작하게 만들어주는 RxCocoa의 메소드,
// .observe(on: MainScheduler.instance)를 반드시 사용했어야 했다.

// 그런데 만약에 Observable로부터 값을 받는 도중에 갑자기 에러가 생겼다고 해보자.
// 그러면 onError가 뱉어지면서 Stream이 끊어지겠지?
// 근데 그렇게 되면 데이터가 끊어지게 되므로 UI를 그리는 데에 심각한 에러가 발생할 것 아닌가?
// 이런 상횡일 경우 어떻게 해야 할까?
// 이 때 사용하는 것이 바로 asDriver()라는 메소드이다.
// asDriver를 사용함으로 onError를 뱉고 Stream을 끊어버리는 대신에
// 에러가 발생할 경우 도출할 값을 정해놓고 Stream은 계속 진행하도록 한다.

// 아래의 예시를 보자.




tableViewCellObservable
    .map { "\($0)" }
    // 만일 map 처리를 하다가 오류가 발생할 경우, 발생하는 모든 String 값에 대하여 "" 값으로 처리하는 것이다.
    .asDriver(onErrorJustReturn: "")
    // 그 이후, "drive 메소드를" 통해서 데이터와 UI 객체를 bind시켜주면 된다.
    .drive(tableView.rx.items(cellIdentifier: "저쩌구", cellType: UITableViewCell.self)) {
        index, item, cell in
        
        // 이런 방식으로 클로저 내부에 각 셀에다가 Observable로부터 받은 값을 할당해주면 된다.
        // 이렇게 처리하면 UITableViewDataSource 프로토콜은 아예 필요가 없어지게 된다. 쓸 필요가 없다. ⭐️⭐️
        // cell.number.text = item.text
    }
    .disposed(by: disposeBag)
