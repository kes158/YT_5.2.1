# YouTube Plus
iOS용 YouTube 강화 트윅으로, 100가지 이상의 커스터마이징 옵션을 제공합니다.


## 주요 기능
<li>동영상, 오디오(트랙 선택 포함), 썸네일, 게시물, 프로필 사진 다운로드</li>
<li>동영상, 댓글, 게시물 정보 복사</li>
<li>UI 커스터마이징: 피드 요소 제거, 탭 순서 변경, OLED 모드, Shorts 전용 모드</li>
<li>플레이어 설정: 제스처, 기본 화질, 기본 오디오 트랙</li>
<li>설정 저장·불러오기·초기화, 캐시 수동/자동 삭제</li>
<li>SponsorBlock 내장</li>
<li>그 외 훨씬 더 많은 기능들</li>
<br>

**YouTube Plus 설정은 YouTube 앱 설정 안에 있어요**


## GitHub Actions으로 YouTube Plus 앱 빌드하기
> [!NOTE]
> 처음 시작하는 경우, 아래 단계를 먼저 완료해주세요:
>
> 1. 오른쪽 상단의 Fork 버튼으로 이 저장소를 포크하세요
> 2. 포크한 저장소에서 **Repository Settings** > **Actions** 로 이동해서 **Read and Write** 권한을 활성화하세요

<details>
  <summary>YouTube Plus 앱 빌드 방법</summary>
  <ol>
    <li><strong>Sync fork</strong>를 클릭하고, 브랜치가 오래됐다면 <strong>Update branch</strong>를 눌러 최신화하세요.</li>
    <li>포크한 저장소의 <strong>Actions 탭</strong>으로 이동해서 <strong>Create YouTube Plus app</strong>을 선택하세요.</li>
    <li>오른쪽의 <strong>Run workflow</strong> 버튼을 클릭하세요.</li>
    <li>원하는 트윅을 체크/해제하세요. 자세한 내용은 <a href="#통합-트윅-상세-정보">통합 트윅 상세 정보</a> 섹션을 참고하세요.</li>
    <li>복호화된 .ipa 파일을 준비한 뒤 파일 공유 서비스(filebin.net, filemail.com, Dropbox 등)에 업로드하고, 직접 다운로드 링크를 입력란에 붙여넣으세요.</li>
    <li><strong>주의:</strong> 웹페이지 링크가 아니라 파일 직접 다운로드 링크여야 해요. 아니면 빌드가 실패해요.</li>
    <li>릴리즈에서 트윅 버전을 입력하세요 (기본값은 최신 릴리즈). BundleID와 표시 이름도 원하면 바꿀 수 있어요.</li>
    <li>입력값을 확인한 후 <strong>Run workflow</strong>를 눌러 빌드를 시작하세요.</li>
    <li>빌드가 끝나면 포크한 저장소의 Releases 섹션에서 앱을 다운로드할 수 있어요. (Releases 섹션이 안 보이면 저장소 URL 끝에 /releases를 붙여보세요. 예: github.com/사용자이름/YTLite/releases)</li>
  </ol>
</details>

<details>
  <summary>직접 구한 YouTube Plus 트윅 파일로 빌드하는 방법</summary>
  <ol>
    <blockquote>
      <p><strong>주의:</strong> 이 옵션은 주로 직접 가지고 있는 베타 파일로 빌드할 때 사용해요. 일반적인 경우엔 필요 없어요.</p>
    </blockquote>
    <li><strong>Sync fork</strong>를 클릭하고, 브랜치가 오래됐다면 <strong>Update branch</strong>를 눌러 최신화하세요.</li>
    <li>포크한 저장소의 <strong>Actions 탭</strong>으로 이동해서 <strong>[BETA] Build YouTube Plus app</strong>을 선택하세요.</li>
    <li>오른쪽의 <strong>Run workflow</strong> 버튼을 클릭하세요.</li>
    <li>원하는 트윅을 체크/해제하세요. 자세한 내용은 <a href="#통합-트윅-상세-정보">통합 트윅 상세 정보</a> 섹션을 참고하세요.</li>
    <li>복호화된 .ipa 파일을 준비한 뒤 파일 공유 서비스에 업로드하고, 직접 다운로드 링크를 붙여넣으세요.</li>
    <li>베타 트윅 파일도 파일 공유 서비스에 업로드한 뒤 직접 링크를 <strong>YouTube Plus tweak file URL</strong> 입력란에 붙여넣으세요. BundleID와 표시 이름도 원하면 바꿀 수 있어요.</li>
    <li><strong>주의:</strong> 웹페이지 링크가 아니라 파일 직접 다운로드 링크여야 해요. 아니면 빌드가 실패해요.</li>
    <li>입력값을 확인한 후 <strong>Run workflow</strong>를 눌러 빌드를 시작하세요.</li>
    <li>빌드가 끝나면 포크한 저장소의 Releases 섹션에서 앱을 다운로드할 수 있어요.</li>
  </ol>
</details>

## 지원 YouTube 버전
<ul>
   <li><strong>최근 확인된 버전:</strong> <em>21.16.2</em></li>
   <li><strong>테스트 날짜:</strong> <em>2026년 4월 23일</em></li>
   <li><strong>YouTube Plus 버전:</strong> <em>5.2.1</em></li>
</ul>

## 통합 트윅 상세 정보
<details>
  <summary>YouPiP</summary>
  <p>YouPiP은 <a href="https://github.com/PoomSmart">PoomSmart</a>이 개발한 트윅으로, iOS YouTube 앱에서 네이티브 PiP(화면 속 화면) 기능을 활성화해요.</p>
  <p><strong>YouPiP 설정</strong>은 <strong>YouTube 설정</strong> 안에 있어요.</p>
  <p>소스 코드 및 추가 정보는 <a href="https://github.com/PoomSmart/YouPiP">PoomSmart의 GitHub 저장소</a>에서 확인할 수 있어요.</p>
</details>

<details>
  <summary>YTUHD</summary>
  <p>YTUHD는 <a href="https://github.com/PoomSmart">PoomSmart</a>이 개발한 트윅으로, iOS YouTube 앱에서 1440p(2K) 및 2160p(4K) 해상도를 잠금 해제해요.</p>
  <p><strong>YTUHD 설정</strong>은 <strong>YouTube 설정</strong>의 <strong>동영상 화질 설정</strong> 섹션에 있어요.</p>
  <p>소스 코드 및 추가 정보는 <a href="https://github.com/PoomSmart/YTUHD">PoomSmart의 GitHub 저장소</a>에서 확인할 수 있어요.</p>
</details>

<details>
  <summary>Return YouTube Dislikes</summary>
  <p>Return YouTube Dislikes는 <a href="https://github.com/PoomSmart">PoomSmart</a>이 개발한 트윅으로, YouTube 앱에서 싫어요 수를 다시 보여줘요.</p>
  <p><strong>Return YouTube Dislikes 설정</strong>은 <strong>YouTube 설정</strong> 안에 있어요.</p>
  <p>소스 코드 및 추가 정보는 <a href="https://github.com/PoomSmart/Return-YouTube-Dislikes">PoomSmart의 GitHub 저장소</a>에서 확인할 수 있어요.</p>
</details>

<details>
  <summary>YouQuality</summary>
  <p>YouQuality는 <a href="https://github.com/PoomSmart">PoomSmart</a>이 개발한 트윅으로, 동영상 오버레이에서 바로 화질을 확인하고 변경할 수 있어요.</p>
  <p><strong>YouQuality 활성화</strong>는 <strong>YouTube 설정</strong>의 <strong>동영상 오버레이</strong> 섹션에서 할 수 있어요.</p>
  <p>소스 코드 및 추가 정보는 <a href="https://github.com/PoomSmart/YouQuality">PoomSmart의 GitHub 저장소</a>에서 확인할 수 있어요.</p>
</details>

<details>
  <summary>DontEatMyContent</summary>
  <p>DontEatMyContent는 <a href="https://github.com/therealFoxster">therealFoxster</a>가 개발한 트윅으로, iOS YouTube 앱에서 노치/다이나믹 아일랜드가 2:1 비율 동영상 콘텐츠를 가리는 문제를 해결해줘요.</p>
  <p><strong>DontEatMyContent 설정</strong>은 <strong>YouTube 설정</strong> 안에 있어요.</p>
  <p>소스 코드 및 추가 정보는 <a href="https://github.com/therealFoxster/DontEatMyContent">therealFoxster의 GitHub 저장소</a>에서 확인할 수 있어요.</p>
</details>
