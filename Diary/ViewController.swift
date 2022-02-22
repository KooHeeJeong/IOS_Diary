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
    private var diaryList = [Diary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCollectionView()
        
    }
    
    private func configureCollectionView() {
        self.collectionView.collectionViewLayout = UICollectionViewLayout()
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let wirteDiaryViewContoller = segue.destination as? WriteDiaryViewController {
            wirteDiaryViewContoller.delegate = self
        }
    }
    
    private func dateToString(date : Date) -> String {
        let formmater = DateFormatter()
        formmater.dateFormat = ("yyyy년 MM월 dd일(EEEEE)")
        formmater.locale = Locale(identifier: "ko_KR")
        return formmater.string(from: date)
    }
}

extension ViewController : WriteDiaryViewDelegete {
    func didSelectReigster(diary: Diary) {
        //sugue 프로토코로 받은 diary 배열 값 저장
        self.diaryList.append(diary)
        self.collectionView.reloadData()
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
        cell.dateLabel.text = diary.date
//        cell.dateLabel.text = dateToString(date: diary.date)
        
        return cell
                
    }
}

extension ViewController : UICollectionViewDelegateFlowLayout {
    //셀의 사이즈를 설정하는 메소드
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //CGSIZE 값 으로 셀 사이즈를 측정 기본 아이폰 값 나누기 20
        return CGSize(width: UIScreen.main.bounds.width/2 - 20 , height: 200)
    }
}
