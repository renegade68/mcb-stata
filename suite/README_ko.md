# Stata에서 최선 집단과 비교하기

독립적인 여러 집단의 평균을 알 수 없는 최선의 모집단 평균과 비교합니다.
일원 정규모형과 집단 간 공통 분산을 가정합니다. [English guide](README.md).

**Suite 0.1.6 — 배포 후보판.** Stata 16.1 이상이 필요하며, 일반적인 실행에는 R·Python·SSC 패키지가 필요하지 않습니다.

| 명령 | 입력과 용도 | 버전 |
|---|---|---|
| `mcbhsu` | 개별 관측값으로 최선 후보 집단과 거리 구간 계산 | 0.9.2 |
| `mcbhsus` | 집단별 표본 수·평균·표준편차 등 요약통계로 계산 | 0.1.1 |
| `mcbhsumargin` | 거리 구간을 사용자가 정한 허용 거리와 비교 | 0.1.1 |

## 내려받고 설치하기

1. 전체 suite ZIP을 내려받습니다. GitHub에서는 **Code > Download ZIP** 또는 제공된 버전별 배포 ZIP을 사용합니다.
2. 압축을 모두 풀고 새 Stata 세션을 엽니다.
3. **File > Change working directory** 또는 `cd "압축을 푼 폴더 경로"`로 `install_mcbhsu_suite.do`가 있는 폴더로 이동합니다.
4. 다음을 실행합니다.

```stata
do install_mcbhsu_suite.do
which mcbhsu
which mcbhsus
which mcbhsumargin
help mcbhsu_suite
```

설치기는 파일을 검사한 뒤 네 패키지를 차례로 설치합니다. 중간 실패 시 자동으로 전체 설치를 되돌리지는 않습니다.
성공하면 `MCBHSU_SUITE_INSTALL_PASSED`가 표시됩니다. 재설치할 때도 압축을 푼 전체 폴더를 유지하세요.
내려받은 로컬 파일로 설치하므로 별도의 원격 `net install` 주소가 필요하지 않습니다.
[후보판 상태와 방법별 범위](docs/release-status.md)를 확인하세요.
업데이트 후에는 새 Stata 세션을 사용하세요. 작업 폴더에 남은 예전 명령이 먼저 읽힐 수 있으므로 `which`로 경로를 확인할 수 있습니다.

## 첫 예제 실행하기

먼저 사용 중인 데이터를 저장하세요. 아래 예제는 메모리의 데이터를 대체하고 결과 파일을 생성하며, 다시 실행하면 같은 이름의 결과를 덮어씁니다.
설치 파일이 있는 폴더에서 실행합니다.

```stata
do first_steps.do
* 개별 자료 → 요약통계 → 허용 거리의 전체 흐름
do demo_mcbhsu_suite.do
```

첫 예제는 자체 데이터를 만들고 `MCBHSU_FIRST_STEPS_PASSED`로 끝납니다.
그래프와 결과는 `onboarding_example/`에, 전체 흐름의 결과는 `suite_example/`에 저장됩니다.
[예제 결과 해석](docs/quickstart.md)을 참고하세요.

## 새 환경의 설치 확인

데이터를 저장하고 새 Stata 세션에서 압축을 푼 폴더로 이동한 뒤 실행합니다.

```stata
do validate_installation.do
```

새 폴더에 격리 설치·재설치하고 설치된 도움말과 예제를 실행합니다.
`MCBHSU_INSTALLATION_CHECK_PASSED`가 나타나면 완료입니다.
이미 있는 결과 폴더는 사용하지 않습니다. [외부 검증 안내](docs/external-validation.md)에
전달할 결과 파일을 설명했습니다. 자동 업로드는 없습니다.

## 자신의 자료에 적용하기

`y`를 결과 변수, `treatment`를 집단 변수로 바꾸세요.

```stata
* 최선일 가능성을 배제할 수 없는 집단
mcbhsu y, over(treatment) graph

* 최선의 모집단 평균까지의 거리
mcbhsu y, over(treatment) method(edwardshsu) graph

* 바로 이어서: 거리가 5 이하인가?
mcbhsumargin, epsilon(5) graph
```

기본값은 평균이 클수록 좋다는 설정입니다. 작을수록 좋다면 분석 명령에 `best(min)`을 추가하세요.
`epsilon(5)`의 5는 예시입니다. 결과 변수의 단위와 연구 목적에 맞춰 허용 거리를 정해야 합니다.
요약통계 입력은 `help mcbhsus`와 `do demo_mcbhsus.do`를 참고하세요.

후보로 남았다는 것은 동일하거나 동등하다는 뜻이 아닙니다. 기본 constrained 구간은 구성상 0을 포함하므로
0 포함 여부 대신 `candidate`를 읽어야 합니다. 거리와 허용 거리 판단은 별개의 질문입니다.
[계산 방법과 가정](docs/methods.md)에 정의와 경계 처리 방침을 설명했습니다.

## 적용 범위와 확인

2–50개 집단, 불균형 표본 수, 숫자·문자 집단 변수, 80–99.9% 신뢰수준을 지원합니다.
독립 정규 관측값, 공통 분산, 양의 잔차 변동을 요구합니다. 이분산·공변량·반복측정·군집 자료에는 그대로 적용할 수 없습니다.
패널·프런티어 연구는 이 배포판의 사용자용 명령에 포함되어 있지 않습니다.
일부 불균형 설계와 작은 꼬리확률에서는 수치적분에 시간이 걸립니다.

데이터를 저장한 뒤 `do verify.do`로 14개 자체 점검을 실행할 수 있습니다.
이번 0.1.6은 참고문헌·문서 개정판이며 macOS Stata/MP 16.1에서 설치·재설치와 예제를 확인했습니다.
Windows 설치·재설치 및 수치 검증은 0.1.5에서 완료되었으며 0.1.6을 Windows에서 다시 실행한 것은 아닙니다. [검증 범위와 한계](docs/validation.md)를 참고하세요.
지원하는 정규·공통분산 모형은 Edwards–Hsu 1983 논문과 1984 JASA 정오표를 대조했습니다.
0.9.2 엔진은 원문대로 모든 다른 집단을 사용하여 상한을 계산합니다. 출판 예제와 회귀검증 범위는 [검증 기록](docs/validation.md)을 확인하세요.
새 허용거리 명령을 사용하려면 이전 버전에서 저장한 결과를 이번 suite로 다시 계산하세요. 상용 소프트웨어 실행 결과와의 인증된 동등성은 주장하지 않습니다.

문의 시 명령·버전·작은 재현 예제·오류 메시지를 함께 제시하세요.
Copyright 2026 Choonjoo Lee. [AFL-3.0](LICENSE). [인용 정보](CITATION.cff) · [변경 사항](CHANGELOG.md).

재실행 시에는 기존 결과 폴더를 덮어쓰지 않습니다. 다른 이름을 지정하세요:

```stata
do validate_installation.do "windows_check_015_second"
```

폴더 중복 오류와 로그에 기록된 checksum r(459)는 별개의 오류입니다.

## 참고문헌과 인용

[완전한 참고문헌과 방법별 근거](docs/methods.md#references-and-attribution) · [BibTeX](docs/references.bib) · [소프트웨어 인용](CITATION.cff)
