//
//  StarCell.swift
//  Diary
//
//  Created by 구희정 on 2022/02/20.
//

import UIKit

class StarCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    //UI 뷰가 생성이 될 때 생성자를 통해 객체가 생성이 된다.
    //아래 코드는 Cell 의 테투리를 형성
    required init?(coder: NSCoder) {
      super.init(coder: coder)
      self.contentView.layer.cornerRadius = 3.0
      self.contentView.layer.borderWidth = 1.0
      self.contentView.layer.borderColor = UIColor.black.cgColor
    }
}
