# FinMVP Landing Page (Single-file)

중학생 금융 학습 플랫폼 MVP의 시장 수요 검증을 위한 단일 파일 랜딩페이지입니다.

## Run

- `index.html`을 브라우저로 열면 됩니다.

## Deploy (GitHub → Vercel)

이 프로젝트는 정적 파일(`index.html`)만 포함하며, Vercel이 자동 배포할 수 있도록 `vercel.json`이 포함되어 있습니다.

### 1) Git 설치

Windows에서 Git이 없다면 설치 후 새 터미널을 열어주세요.

### 2) GitHub에 업로드

```bash
cd /d D:\HANA
git init
git add .
git commit -m "Initial landing page"
git branch -M main
git remote add origin <YOUR_GITHUB_REPO_URL>
git push -u origin main
```

### 3) Vercel 연동

Vercel에서 **New Project** → 방금 만든 GitHub 레포 선택 → Deploy.

