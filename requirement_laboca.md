#project-overview (프로젝트 개요)
해당 앱은 사용자가 영어 및 다른 언어에 대한 단어를 정리할 수 있는 앱입니다. sqlite를 활용해 단어를 저장하고 편리하게 사용할 수 있습니다. 

#project name
eng_word_storage

#feature-requirements (기능 요구사항)

1. flutter, sqflite 그리고 편의를 위한 shared_preferences, flutter_slidable 그리고 추후 인앱결제와 광고를 위한google_mobile_ads, in_app_purchase를 사용합니다.

2. 화면은 크게 총 2가지로 각각 세부 페이지를 가지고 있습니다. 첫번째 화면은 그동안 등록한 단어를 무한 스크롤을 통해 확인 할 수 있어야합니다. 기기에 무리가 가지 않는 선에서 최대한 많은 단어를 보여주어야합니다. 그리고 오른쪽 하단에 float된 + 아이콘을 클릭하면 새로운 단어를 등록할 수 있는 창이 떠야합니다. 두번째 페이지는 셋팅 페이지입니다. 단어를 csv로 export하는 기능과 app에 대한 설명과 버그 그리고 피드백을 위한 세부창들이 존재합니다.

3. 2번 항목의 폼은 읽기 쉽고 사용자 친화적이어야 하며, 멋진 UI와 애니메이션을 갖추어야 합니다. 듀오링고와 비슷하면 좋겠습니다.

4. 데이터 저장 및 조회는 sqflite를 통해 이루어집니다.

5. 단어를 추가할때는 입력할 수 있는 칸이 여러개 존재합니다. 단어와, 설명(혹은 뜻), 추가적인 메모(선택사항) 그리고 가능하다면 녹음기를 사용해서 발음을 같이 저장할 수 있으면 좋겠습니다.(선택사항)


#rules (규칙)

- 모든 새로운 컴포넌트는 특별히 명시되지 않는 한 /components에 생성되어야 하며 example_component.tsx와 같이 이름 지어져야 합니다.
- 모든 새로운 페이지는 /app/pages에 생성되어야 하며 example_page.tsx와 같이 이름 지어져야 합니다.
