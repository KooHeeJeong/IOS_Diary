//
//  ViewController.swift
//  Diary
//
//  Created by 구희정 on 2022/02/20.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    //다이어이 리스트 배열 초기화
    private var diaryList = [Diary]() {
        //프로퍼티 옵저버
        //didSet이 될 때 다이어리 일기가 변경 또는 추가가 되면 저장
        didSet {
            self.saveDiaryList()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCollectionView()
        self.loadDiaryList()
        
    }
    
    //CollectionView 에 세팅하는 값
    private func configureCollectionView() {
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let wirteDiaryViewContoller = segue.destination as? WriteDiaryViewController {
            wirteDiaryViewContoller.delegate = self
        }
    }
    //Date타입으로 전달 받으면 문자열로 바꿔주는 메소드
    private func dateToString(date : Date) -> String {
        let formmater = DateFormatter()
        formmater.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formmater.locale = Locale(identifier: "ko_KR")
        return formmater.string(from: date)
    }
    //Diary 가 저장이 되도록 만드는 메소드
    private func saveDiaryList() {
        let date = self.diaryList.map{
            [
                "title" : $0.title,
                "contnets" : $0.contents,
                "date" : $0.date,
                "isStar" : $0.isStar
            ]
        }
        let userDefaults = UserDefaults.standard
        userDefaults.set(date, forKey: "diaryList")
        
    }
    
    //저장된 UserDefault 에서 값을 가져오기.
    private func loadDiaryList() {
        let userDefault = UserDefaults.standard
        guard let data = userDefault.object(forKey: "diaryList") as? [[String: Any]] else { return }
        self.diaryList = data.compactMap{
            guard let title = $0["title"] as? String else { return nil }
            guard let contents = $0["contents"] as? String else { return nil }
            guard let date = $0["date"] as? Date else { return nil}
            guard let isStar = $0["isStar"] as? Bool else { return nil }
            
            return Diary(title: title, contents: contents, date: date, isStar: isStar)
        }
        //sorted의 고차함수를 사용
        //일기가 날짜 기준으로 최신순으로 보여준다.
        self.diaryList = self.diaryList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
    }
}



//CollectionView 에서 보여지는 컨텐츠를 관리하는 메소드
extension ViewController : UICollectionViewDataSource {
    
    //지정된 세션을 표시할 갯수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.diaryList.count
    }
    
    //컬렉션뷰에 지정된 위치에 표시할 셀을 요청하는 메소드
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //DiaryCell 로 다운캐스팅에 실패하면 UICollectionViewCell 이 빈 값으로 리턴
        
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiaryCell", for: indexPath) as? DiaryCell else { return UICollectionViewCell() }
        let diary = self.diaryList[indexPath.row]
        cell.titleLabel.text = diary.title
        cell.dateLabel.text = self.dateToString(date: diary.date)
        return cell
                
    }
}

extension ViewController : UICollectionViewDelegateFlowLayout {
    //셀의 사이즈를 설정하는 메소드
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      return CGSize(width: (UIScreen.main.bounds.width / 2) - 20, height: 200)
    }
}

extension ViewController : WriteDiaryViewDelegete {
    func didSelectReigster(diary: Diary) {
        //sugue 프로토코로 받은 diary 배열 값 저장
        self.diaryList.append(diary)
        
        //sorted의 고차함수를 사용
        //일기가 날짜 기준으로 최신순으로 보여준다.
        self.diaryList = self.diaryList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
        self.collectionView.reloadData()
    }
}

extension ViewController : UICollectionViewDelegate {
    //특정 Cell 이 선택 되었을 때 하는 메서드
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //push 하는 메서드 구현
        guard let viewContoller = self.storyboard?.instantiateViewController(identifier: "DiaryDetailViewController") as? DiaryDetailViewController else { return }
        let diary = self.diaryList[indexPath.row]
        viewContoller.diary = diary
        viewContoller.indexPath = indexPath
        viewContoller.delegate = self
        self.navigationController?.pushViewController(viewContoller, animated: true)
    }
}
extension ViewController : DiaryDetailViewDelegate {
    func didSelectDelete(indexPath: IndexPath) {
        self.diaryList.remove(at: indexPath.row)
        self.collectionView.deleteItems(at: [indexPath])
    }
}
