export type Lang = 'vi' | 'en'

export const LANG_COOKIE = 'gw_lang'

type Dict = Record<string, { vi: string; en: string }>

export const dict: Dict = {
  // common
  logout: { vi: 'Đăng xuất', en: 'Log out' },
  switchRole: { vi: 'Đổi vai trò', en: 'Switch role' },
  account: { vi: 'Tài khoản', en: 'Account' },
  cancel: { vi: 'Huỷ', en: 'Cancel' },
  save: { vi: 'Lưu', en: 'Save' },
  back: { vi: 'Quay lại', en: 'Back' },
  loading: { vi: 'Đang tải…', en: 'Loading…' },

  // app shell brand
  brandParent: { vi: 'Phụ huynh', en: 'Parent' },
  brandKids: { vi: 'Học vui, lớn khôn', en: 'Learn & grow' },

  // parent nav
  navDashboard: { vi: 'Bảng điều khiển', en: 'Dashboard' },
  navCreateTask: { vi: 'Tạo nhiệm vụ', en: 'Create task' },
  navLessons: { vi: 'Bài học', en: 'Lessons' },
  navMemories: { vi: 'Kỷ niệm', en: 'Memories' },
  navSettings: { vi: 'Cài đặt', en: 'Settings' },

  // child nav
  navTasks: { vi: 'Nhiệm vụ', en: 'Tasks' },
  navJars: { vi: '3 Hũ tiền', en: '3 Jars' },
  navDreams: { vi: 'Ước mơ', en: 'Dreams' },
  navLearn: { vi: 'Học bài', en: 'Learn' },
  navAchievements: { vi: 'Thành tích', en: 'Achievements' },
  navChat: { vi: 'Chat AI', en: 'AI Chat' },

  // role page
  whoAreYou: { vi: 'Bạn là ai?', en: 'Who are you?' },
  chooseRole: { vi: 'Chọn vai trò để tiếp tục', en: 'Choose a role to continue' },
  parent: { vi: 'Cha mẹ', en: 'Parent' },
  parentSub: { vi: 'Quản lý & duyệt nhiệm vụ', en: 'Manage & approve tasks' },
  child: { vi: 'Con', en: 'Child' },
  childSub: { vi: 'Làm nhiệm vụ & kiếm xu', en: 'Do tasks & earn coins' },
  security: { vi: 'Bảo mật', en: 'Secured' },

  // auth
  login: { vi: 'Đăng nhập', en: 'Log in' },
  loginWelcome: { vi: 'Chào mừng bạn trở lại với GrowWise', en: 'Welcome back to GrowWise' },
  loginGoogle: { vi: 'Đăng nhập với Google', en: 'Continue with Google' },
  or: { vi: 'hoặc', en: 'or' },
  email: { vi: 'Email', en: 'Email' },
  password: { vi: 'Mật khẩu', en: 'Password' },
  noAccount: { vi: 'Chưa có tài khoản?', en: "Don't have an account?" },
  haveAccount: { vi: 'Đã có tài khoản?', en: 'Already have an account?' },
  register: { vi: 'Đăng ký', en: 'Sign up' },
  registerTitle: { vi: 'Tạo tài khoản phụ huynh', en: 'Create a parent account' },
  fullName: { vi: 'Họ tên', en: 'Full name' },
  confirmPassword: { vi: 'Xác nhận mật khẩu', en: 'Confirm password' },
  agreeTerms: {
    vi: 'Tôi đồng ý với Điều khoản & Chính sách bảo mật',
    en: 'I agree to the Terms & Privacy Policy',
  },
  tagline: { vi: 'Dạy con yêu tiền — đúng cách', en: 'Teach kids to love money — the right way' },

  // parent dashboard
  manageAndTrack: { vi: 'Quản lý nhiệm vụ và theo dõi con', en: 'Manage tasks and track your kids' },
  pendingReview: { vi: 'Chờ duyệt', en: 'Pending review' },
  weeklyCoins: { vi: 'Xu thưởng tuần này', en: "This week's coins" },
  childrenCount: { vi: 'Số con', en: 'Children' },
  newTask: { vi: 'Tạo nhiệm vụ mới', en: 'Create new task' },
  approveQueueEmpty: { vi: 'Chưa có bài nào chờ duyệt 🎉', en: 'No submissions to review 🎉' },
  approve: { vi: 'Duyệt & thưởng xu', en: 'Approve & reward' },
  reject: { vi: 'Từ chối', en: 'Reject' },

  // child home
  hiDoTasks: { vi: 'Làm nhiệm vụ thôi!', en: "Let's do some tasks!" },
  myTasks: { vi: 'Nhiệm vụ của mình', en: 'My tasks' },
  market: { vi: 'Chợ nhiệm vụ', en: 'Task market' },
  submit: { vi: 'Nộp bài', en: 'Submit' },
  resubmit: { vi: 'Nộp lại', en: 'Resubmit' },

  // settings
  manageChildren: { vi: 'Quản lý con', en: 'Manage children' },
  changePin: { vi: 'Đổi mã PIN phụ huynh', en: 'Change parent PIN' },
  subscription: { vi: 'Gói đăng ký', en: 'Subscription' },
  currentPlan: { vi: 'Gói hiện tại', en: 'Current plan' },
  checkMood: { vi: 'Kiểm tra tâm trạng', en: 'Mood check' },

  // memories export
  memoriesTitle: { vi: 'Kỷ niệm của con', en: "Your child's memories" },
  memoriesSub: {
    vi: 'Lưu giữ những khoảnh khắc trưởng thành đáng tự hào',
    en: 'Treasure proud moments of growing up',
  },
  downloadImage: { vi: 'Tải ảnh', en: 'Download' },
  downloadAll: { vi: 'Tải tất cả', en: 'Download all' },
  creatingImage: { vi: 'Đang tạo ảnh…', en: 'Creating image…' },
  exportError: { vi: 'Không tải được ảnh này', en: "Couldn't export this image" },

  // children & subscription management
  addChild: { vi: 'Thêm con', en: 'Add child' },
  childProfiles: { vi: 'Hồ sơ con', en: 'Child profiles' },
  childName: { vi: 'Tên con', en: 'Child name' },
  nameRequired: { vi: 'Vui lòng nhập tên con', en: 'Please enter a name' },
  childAge: { vi: 'Tuổi', en: 'Age' },
  maxReached: { vi: 'Đã đạt số con tối đa của gói', en: 'Plan child limit reached' },
  upgradeFamily: { vi: 'Nâng cấp gói Gia Đình', en: 'Upgrade to Family' },
  viewPlans: { vi: 'Xem các gói', en: 'View plans' },
  upgrade: { vi: 'Nâng cấp', en: 'Upgrade' },
  pricingTitle: { vi: 'Chọn gói phù hợp', en: 'Choose your plan' },
  saving: { vi: 'Đang lưu…', en: 'Saving…' },
}

export type TKey = keyof typeof dict

export function t(lang: Lang, key: TKey): string {
  return dict[key]?.[lang] ?? dict[key]?.vi ?? String(key)
}
