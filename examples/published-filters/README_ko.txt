mcbhsu 논문 재현 예제 — suite 0.1.4용 별도 자료
2026-11-17

필요한 것
Stata 16.1 이상과 설치된 suite 0.1.4:
  mcbhsu 0.9.2, mcbhsus 0.1.1, mcbhsumargin 0.1.1.
외부 실행 프로그램이나 데이터 다운로드는 필요하지 않습니다.
이 예제 묶음은 suite 설치 ZIP을 대체하지 않습니다.

실행 순서
1. 기존 자료를 저장하고 새 Stata 세션을 엽니다.
2. 기존 suite 0.1.4 ZIP을 모두 푼 폴더에서 실행합니다.
     do install_mcbhsu_suite.do
3. 이 예제 묶음의 reproduce_mcbhsu.do가 있는 폴더로 이동하여 실행합니다.
     do reproduce_mcbhsu.do
4. 마지막 MCBHSU_PAPER_EXAMPLE_PASSED 표식을 확인합니다.

기본 결과 폴더는 mcbhsu_paper_results입니다. 이미 있으면 덮어쓰지 않고 중단합니다.
다시 실행하려면 새 폴더 이름을 지정합니다.
     do reproduce_mcbhsu.do "my_second_results"
실행 과정에서 메모리 자료가 교체됩니다.

자료와 단계
- Edwards and Hsu (1983), JASA 78:965–971, 970쪽의 필터 관측값 21개를 입력합니다.
  DOI: https://doi.org/10.2307/2288211
- 7개 필터의 Edwards–Hsu 구간, 필터7을 제외한 6개 필터의 구간을 계산합니다.
- 기본 constrained 방법의 추론 대상과 후보 판정이 다름을 확인합니다.
- 표본 수·평균·표준편차를 만들어 mcbhsus를 실행하고 원자료 결과와 대조합니다.
- 공통 MSE 입력과 best(min) 방향변환도 확인합니다.
- 허용거리 epsilon=25를 적용하고 원자료/요약자료 저장 결과의 판정을 대조합니다.
  25는 이 설명에서 고른 예시값이며 원문에서 정한 기준이 아닙니다.

결과 읽기
7개 필터에서:
- 대조군 집합 S: 5,7.
- 거리 하한이0인 후보 C: 1,3,5,7.
- epsilon=25 안: 5; 밖: 4,6; 판단 유보: 1,2,3,7.
따라서 후보라는 이유만으로 허용거리 안에 있다고 결론 내릴 수 없습니다.
후보에서 제외되었다는 사실도 허용거리25보다 더 나쁘다는 뜻은 아닙니다.

6개 필터 예제에서 S와 C는 모두5입니다. 비교 대상 집합과 pooled MSE가 달라졌습니다.
결과를 본 뒤 유리한 집단만 남기라는 권고가 아닙니다.

주요 산출물
- raw_results.csv / six_filter_results.csv: 출판 예제의 현재 계산값.
- constrained_results.csv: 다른 signed target의 출력.
- filter_summaries.csv / summary_results.csv: 요약 입력과 결과.
- margin_results.csv: 원래 구간·후보와 허용거리 판정.
- checks.csv: 원자료와 요약자료 사이 최대 수치 차이 및 버전.
- filter_comparison.png: 비교 집합 변경에 따른 두 구간 그림.
- practical_margin.png: 허용거리25에 따른 세 가지 판정.
- example.txt: 예제 실행 로그.
각 결과의 .dta 파일은 저장 결과 메타데이터도 포함합니다.
배포 예제의 expected/에는 검증된 CSV와 그림을 담았습니다. 설치 프로그램은 포함하지 않습니다.

확인 범위
새 예제는 macOS Stata/MP16.1에서 실행했습니다. 현재 suite의 외부 Windows 결과는
별도로 수집 중입니다. 이 스크립트가 설치 전체 검증을 대체하지는 않습니다.
외부 설치 검증에는 기존 suite의 do validate_installation.do를 사용합니다.
독립 정규 관측값과 공통 분산을 가정하며 패널·이분산·DEA 분석 예제가 아닙니다.
