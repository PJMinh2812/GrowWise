class AppStrings {
  final String locale;
  const AppStrings._(this.locale);

  static const AppStrings vi = AppStrings._('vi');
  static const AppStrings en = AppStrings._('en');

  static AppStrings of(String locale) => locale == 'en' ? en : vi;

  bool get isEn => locale == 'en';

  // ── Common ────────────────────────────────────────────────────────────────
  String get save       => isEn ? 'Save'       : 'Lưu';
  String get cancel     => isEn ? 'Cancel'     : 'Hủy';
  String get close      => isEn ? 'Close'      : 'Đóng';
  String get confirm    => isEn ? 'Confirm'    : 'Xác nhận';
  String get done       => isEn ? 'Done ✓'    : 'Xong ✓';
  String get approve    => isEn ? 'Approve'    : 'Duyệt';
  String get reject     => isEn ? 'Reject'     : 'Từ chối';
  String get understood => isEn ? 'Got it'     : 'Đã hiểu';
  String get comingSoon => isEn ? 'Coming soon' : 'Sắp có';
  String get optional   => isEn ? '(Optional)' : '(không bắt buộc)';
  String get required_  => isEn ? '(Required)' : '(Bắt buộc)';
  String get skip       => isEn ? 'Skip'       : 'Bỏ qua';
  String get next       => isEn ? 'Next →'     : 'Tiếp theo →';
  String get coins      => isEn ? 'coins'      : 'xu';
  String get daysStr    => isEn ? 'days'       : 'ngày';
  String get yearsOld   => isEn ? 'years old'  : 'tuổi';
  String get version    => isEn ? 'Version 1.0.0 · EXE201 Demo' : 'Version 1.0.0 · EXE201 Demo';

  // ── Splash ────────────────────────────────────────────────────────────────
  String get splashSubtitle => isEn ? 'Financial education for children' : 'Giáo dục tài chính cho trẻ em';

  // ── Auth ─────────────────────────────────────────────────────────────────
  String get welcomeBack      => isEn ? 'Welcome back!'        : 'Chào mừng trở lại!';
  String get emailLabel       => 'Email';
  String get passwordLabel    => isEn ? 'Password'             : 'Mật khẩu';
  String get signIn           => isEn ? 'Sign In'              : 'Đăng nhập';
  String get signInGoogle     => isEn ? 'Sign in with Google'  : 'Đăng nhập với Google';
  String get noAccount        => isEn ? "Don't have an account? " : 'Chưa có tài khoản? ';
  String get signUp           => isEn ? 'Sign Up'              : 'Đăng ký';
  String get forgotPassword   => isEn ? 'Forgot password?'     : 'Quên mật khẩu?';
  String get wrongCredentials => isEn ? 'Wrong email or password: ' : 'Sai email hoặc mật khẩu: ';
  String get googleError      => isEn ? 'Google error: '       : 'Google lỗi: ';
  String get signOut          => isEn ? 'Sign Out'             : 'Đăng xuất';
  String get switchRole       => isEn ? 'Switch role'          : 'Đổi vai trò';
  String get switchToEnglish  => isEn ? 'Switch to Vietnamese' : 'Switch to English';
  String get languageLabel    => isEn ? 'Language'             : 'Ngôn ngữ';

  // Register
  String get createAccount     => isEn ? 'Create Account'        : 'Tạo tài khoản';
  String get fullName          => isEn ? 'Full Name'             : 'Họ và tên';
  String get passwordMin       => isEn ? 'Minimum 6 characters'  : 'Tối thiểu 6 ký tự';
  String get confirmPassword   => isEn ? 'Confirm Password'      : 'Xác nhận mật khẩu';
  String get reenterPassword   => isEn ? 'Re-enter password'     : 'Nhập lại mật khẩu';
  String get termsAgreement    => isEn ? 'I agree to the Terms of Service and Privacy Policy' : 'Tôi đồng ý với Điều khoản sử dụng và Chính sách bảo mật';
  String get orText            => isEn ? 'or'                    : 'hoặc';
  String get continueGoogle    => isEn ? 'Continue with Google'  : 'Tiếp tục với Google';
  String get alreadyAccount    => isEn ? 'Already have an account? ' : 'Đã có tài khoản? ';
  String get errTermsRequired  => isEn ? 'Please agree to the terms of service' : 'Vui lòng đồng ý với điều khoản sử dụng';
  String get errEmailExists    => isEn ? 'Email already registered. Please use another.' : 'Email đã được đăng ký. Vui lòng dùng email khác.';
  String get errTooManyReqs    => isEn ? 'Too many requests. Please try again later.' : 'Quá nhiều yêu cầu. Vui lòng thử lại sau.';
  String get errRegister       => isEn ? 'Registration error: ' : 'Lỗi đăng ký: ';
  String get confirmEmailTitle => isEn ? 'Confirm Email'         : 'Xác nhận email';
  String get goToLogin         => isEn ? 'Go to Login'           : 'Đến trang Đăng nhập';
  String confirmEmailMsg(String email) => isEn
      ? 'We sent a confirmation link to\n$email\n\nPlease check your email and click the confirmation link.'
      : 'Chúng tôi đã gửi link xác nhận đến\n$email\n\nVui lòng kiểm tra email và nhấn vào link xác nhận.';

  // Forgot password
  String get forgotTitle       => isEn ? 'Forgot Password?'      : 'Quên mật khẩu?';
  String get forgotSubtitle    => isEn ? "We'll help you get back in" : 'Chúng tôi sẽ giúp bạn lấy lại';
  String get forgotInstruction => isEn ? 'Enter your registered email to receive a password reset link.' : 'Nhập email đã đăng ký để nhận link đặt lại mật khẩu.';
  String get sendResetLink     => isEn ? 'Send Reset Link'        : 'Gửi link đặt lại mật khẩu';
  String get backToLogin       => isEn ? '← Back to Login'       : '← Quay lại đăng nhập';
  String get emailSentTitle    => isEn ? 'Email Sent!'            : 'Đã gửi email!';
  String get checkInbox        => isEn ? 'Check your inbox'       : 'Kiểm tra hộp thư của bạn';
  String get emailSentMsg      => isEn
      ? 'We sent a password reset link to your email.\n\nPlease check your inbox (including spam) and follow the instructions.'
      : 'Chúng tôi đã gửi link đặt lại mật khẩu đến email của bạn.\n\nVui lòng kiểm tra hộp thư (bao gồm cả thư rác) và làm theo hướng dẫn.';
  String get backToLoginBtn    => isEn ? 'Back to Login'          : 'Quay lại đăng nhập';

  // Reset password
  String get resetTitle        => isEn ? 'Set New Password'       : 'Đặt mật khẩu mới';
  String get resetSubtitle     => isEn ? 'Enter a new password for your account' : 'Nhập mật khẩu mới cho tài khoản của bạn';
  String get newPassword       => isEn ? 'New Password'           : 'Mật khẩu mới';
  String get reenterNew        => isEn ? 'Re-enter new password'  : 'Nhập lại mật khẩu mới';
  String get updatePassword    => isEn ? 'Update Password'        : 'Cập nhật mật khẩu';
  String get resetSuccessTitle => isEn ? 'Reset Successful!'      : 'Đặt lại thành công!';
  String get resetSuccessSub   => isEn ? 'Sign in again with your new password' : 'Hãy đăng nhập lại với mật khẩu mới';
  String get passwordUpdated   => isEn ? 'Password updated!'      : 'Mật khẩu đã được cập nhật!';
  String get canLoginAgain     => isEn ? 'You can log in again with your new password.' : 'Bạn có thể đăng nhập lại với mật khẩu mới.';
  String get loginNow          => isEn ? 'Login Now'              : 'Đăng nhập ngay';
  String get errorPrefix       => isEn ? 'Error: '                : 'Lỗi: ';

  // ── Onboarding ───────────────────────────────────────────────────────────
  String get onb1Title => isEn ? 'Welcome to GrowWise!'    : 'Chào mừng đến GrowWise!';
  String get onb1Desc  => isEn ? 'A financial education platform for children aged 6–12. Learn money management through play!'
                                : 'Nền tảng giáo dục tài chính cho trẻ 6–12 tuổi. Cùng con học quản lý tiền thông qua trò chơi!';
  String get onb2Title => isEn ? '3 Jar Method'            : 'Phương pháp 3 Hũ';
  String get onb2Desc  => isEn ? 'Spend • Save • Share\nChildren learn to divide money from an early age with the classic 3-jar method.'
                                : 'Tiêu dùng • Tiết kiệm • Sẻ chia\nCon học phân chia tài chính từ nhỏ với phương pháp 3 hũ kinh điển.';
  String get onb3Title => isEn ? 'Gamified Tasks'          : 'Nhiệm vụ Gamification';
  String get onb3Desc  => isEn ? 'Parents assign chores → Children complete → Earn coins! Learn responsibility through fun.'
                                : 'Bố mẹ giao việc nhà → Con hoàn thành → Nhận Xu thưởng! Học trách nhiệm qua trò chơi thú vị.';
  String get onb4Title => isEn ? 'AI Bonding Reminder'     : 'AI Bonding Reminder';
  String get onb4Desc  => isEn ? 'AI reminds parents to praise their child, send voice notes. Strengthen family bonds every day.'
                                : 'AI nhắc nhở bố mẹ khen con, gửi Voice Note. Tăng kết nối tình cảm gia đình mỗi ngày.';
  String get onb5Title => isEn ? 'Dream Jar'               : 'Dream Jar';
  String get onb5Desc  => isEn ? 'Children set goals to buy their favorite items. Earn coins from tasks to achieve dreams!'
                                : 'Con đặt mục tiêu mua đồ yêu thích. Tích Xu từ nhiệm vụ để đạt ước mơ!';
  String get getStarted => isEn ? 'Get Started! 🚀' : 'Bắt đầu ngay! 🚀';

  // ── Role Selection ────────────────────────────────────────────────────────
  String get hiGreeting    => isEn ? 'Hello! 👋'             : 'Xin chào! 👋';
  String get whoAreYou     => isEn ? 'Who are you?'          : 'Bạn là ai?';
  String get chooseRole    => isEn ? 'Choose your role to continue' : 'Chọn vai trò để tiếp tục vào ứng dụng';
  String get parent        => isEn ? 'Parent'                : 'Phụ huynh';
  String get parentSubtitle => isEn ? 'Assign tasks, track progress\nand reward your child' : 'Giao việc, theo dõi tiến độ\nvà khen thưởng con';
  String get childSubtitle => isEn ? 'Complete tasks, earn coins\nand achieve your dreams!' : 'Làm nhiệm vụ, tích xu\nvà thực hiện ước mơ!';
  String get demoMode      => isEn ? 'Demo Mode — Sample Data' : 'Demo Mode — Dữ liệu mẫu';
  String get badgeCreateTask => isEn ? 'Assign Task' : 'Giao việc';
  String get badgeStats    => isEn ? 'Stats'         : 'Thống kê';
  String get badgeAI       => isEn ? 'AI Bonding'    : 'AI Bonding';
  String get badgeTasks    => isEn ? 'Tasks'         : 'Nhiệm vụ';
  String get badge3Jars    => isEn ? '3 Jars'        : '3 Hũ';
  String get badgeDreams   => isEn ? 'Dreams'        : 'Ước mơ';

  // ── Setup ─────────────────────────────────────────────────────────────────
  String get setupTitle       => isEn ? 'Add Child Profile'           : 'Thêm hồ sơ con';
  String get setupSubtitle    => isEn ? "Let's start the GrowWise journey together!" : 'Cùng con bắt đầu hành trình GrowWise!';
  String get chooseAvatar     => isEn ? 'Choose avatar for your child' : 'Chọn avatar cho con';
  String get uploadPhoto      => isEn ? 'Upload photo'                : 'Tải ảnh lên';
  String get removePhoto      => isEn ? 'Remove photo'               : 'Xóa ảnh';
  String get childNameLabel   => isEn ? "Child's Name"                : 'Tên con';
  String get childNameHint    => isEn ? 'E.g: Tom, Lily, Bee...'      : 'VD: Tôm, Bống, Bi...';
  String get childAgeLabel    => isEn ? "Child's Age"                 : 'Tuổi con';
  String get childAgeHint     => 'VD: 8';
  String get startJourney     => isEn ? 'Start the Journey!'          : 'Bắt đầu hành trình!';

  // ── Child Dashboard ───────────────────────────────────────────────────────
  String get tabHome        => isEn ? 'Home'      : 'Trang chủ';
  String get tabTasks       => isEn ? 'Tasks'     : 'Nhiệm vụ';
  String get tabJars        => isEn ? 'Jars'      : '3 Hũ';
  String get tabDreams      => isEn ? 'Dreams'    : 'Ước mơ';
  String get tabLearn       => isEn ? 'Learn'     : 'Học';
  String get coinsAvailable => isEn ? 'coins available' : 'xu đang có';
  String get noTasksYoung   => isEn ? 'No tasks today! 🎉' : 'Chưa có việc hôm nay! 🎉';
  String get noTasksOlder   => isEn ? 'Nothing to do!'     : 'Không có việc gì cần làm!';
  String get noTasksSub     => isEn ? 'Parents have not assigned any tasks today' : 'Bố/Mẹ chưa giao việc hôm nay';
  String get tasksTodaySection => isEn ? 'Tasks Today'        : 'Nhiệm vụ hôm nay';
  String get jarsSection    => isEn ? 'My Jars'              : 'Hũ tiền của con';
  String get pendingApproval => isEn ? '⏳ Waiting for approval...' : '⏳ Đang chờ duyệt...';
  String get newBadge       => isEn ? 'New Badge!'           : 'Huy hiệu mới!';
  String get congratsBadge  => isEn ? 'You are amazing! 🎊'  : 'Con thật tuyệt vời! 🎊';
  String get viewAllBadges  => isEn ? 'View all'             : 'Xem tất cả';
  String get excellent      => isEn ? 'Awesome! 🎉'          : 'Tuyệt! 🎉';

  // ── Child Tasks ───────────────────────────────────────────────────────────
  String get tasksTitle       => isEn ? 'Tasks'                      : 'Nhiệm vụ';
  String get parentOnlyMsg    => isEn ? 'Only Parents can add new tasks!' : 'Chỉ Bố/Mẹ mới có thể thêm nhiệm vụ mới!';
  String get tabTodo          => isEn ? 'To do'                      : 'Cần làm';
  String get tabDone          => isEn ? 'Done'                       : 'Đã xong';
  String get emptyTodo        => isEn ? 'Nothing to do!'             : 'Không có việc gì cần làm!';
  String get emptyTodoSub     => isEn ? 'Parents have not assigned any tasks today' : 'Bố/Mẹ chưa giao việc gì hôm nay';
  String get emptyDoneSub     => isEn ? 'Complete tasks to earn coins!' : 'Hãy hoàn thành nhiệm vụ để tích lũy Xu nhé!';
  String get exploreOther     => isEn ? 'Explore other activities'   : 'Khám phá hoạt động khác';
  String get submitProofBtn   => isEn ? 'Done — Submit Proof'        : 'Đã làm xong — Nộp bằng chứng';
  String get waitingReview    => isEn ? 'Waiting for Parent review...' : 'Đang chờ Bố/Mẹ duyệt...';
  String get submitProofTitle => isEn ? 'Submit Proof'               : 'Nộp bằng chứng hoàn thành';
  String get photoHint        => isEn ? 'Take or choose a proof photo' : 'Chụp hoặc chọn ảnh bằng chứng';
  String get takePhoto        => isEn ? 'Camera'                     : 'Chụp ảnh';
  String get gallery          => isEn ? 'Gallery'                    : 'Thư viện';
  String get submitting       => isEn ? 'Submitting...'              : 'Đang nộp...';
  String get submitFinal      => isEn ? 'Submit to Parent'           : 'Nộp bài cho Bố/Mẹ duyệt';
  String get submittedMsg     => isEn ? '📸 Submitted! Waiting for parent 🎉' : '📸 Đã nộp! Đợi Bố/Mẹ duyệt nhé 🎉';
  String get errPickImage     => isEn ? 'Cannot pick image: '        : 'Không thể chọn ảnh: ';
  String get errNoPhoto       => isEn ? 'Please take or choose a proof photo before submitting!' : 'Vui lòng chụp hoặc chọn ảnh bằng chứng trước khi nộp!';
  String taskSubtitle(int todo, int done) => isEn ? '$todo to do · $done done' : '$todo việc cần làm · $done đã xong';

  // ── Child Jars ────────────────────────────────────────────────────────────
  String get jarsTitle      => isEn ? 'My Jars'      : 'Hũ tiền';
  String get totalLabel     => isEn ? 'Total'        : 'Tổng cộng';
  String get allocationLabel => isEn ? 'Allocation'  : 'Phân bổ';
  String get detailsLabel   => isEn ? 'Details'      : 'Chi tiết';
  String get jarSpend       => isEn ? 'Spend'        : 'Tiêu dùng';
  String get jarSave        => isEn ? 'Save'         : 'Tiết kiệm';
  String get jarShare       => isEn ? 'Share'        : 'Sẻ chia';

  // ── Child Dreams ──────────────────────────────────────────────────────────
  String get dreamsTitle      => isEn ? 'Dreams'               : 'Ước mơ';
  String get addDream         => isEn ? 'Add'                  : 'Thêm';
  String get noDreamsTitle    => isEn ? 'No dreams yet'        : 'Chưa có ước mơ nào';
  String get noDreamsSub      => isEn ? 'Add your first dream!' : 'Thêm ước mơ đầu tiên của con!';
  String get addDreamBtn      => isEn ? 'Add a dream'          : 'Thêm ước mơ';
  String get requestPurchase  => isEn ? 'Request'              : 'Xin mua';
  String get alreadyRequested => isEn ? 'Requested'            : 'Đã xin mua';
  String get confirmBtn       => isEn ? 'Confirm'              : 'Xác nhận';
  String get addDreamTitle    => isEn ? '✨ Add New Dream'      : '✨ Thêm ước mơ mới';
  String get dreamNameLabel   => isEn ? 'Dream name'           : 'Tên ước mơ';
  String get dreamNameHint    => isEn ? 'E.g: Bicycle, Lego...' : 'VD: Xe đạp mini, Lego...';
  String get dreamPriceLabel  => isEn ? 'Coins needed'         : 'Số xu cần';
  String get dreamPriceHint   => 'VD: 500';
  String get chooseIcon       => isEn ? 'Choose icon'          : 'Chọn biểu tượng';
  String get addDreamConfirm  => isEn ? 'Add Dream'            : 'Thêm ước mơ';
  String get confirmBuyTitle  => isEn ? 'Confirm Purchase'     : 'Xác nhận mua';
  String get photoOfPurchase  => isEn ? 'Photo of purchased item' : 'Chụp ảnh món đồ đã mua';
  String get deletePhoto      => isEn ? 'Remove photo'         : 'Xóa ảnh';
  String get confirmedBuy     => isEn ? 'Confirmed! 🎉'        : 'Xác nhận đã mua! 🎉';
  String dreamProgress(int pct, int cur, int price) =>
      isEn ? '$pct% saved ($cur/$price coins)' : '$pct% đã tích lũy ($cur/$price xu)';

  // ── Achievements ──────────────────────────────────────────────────────────
  String get achievementsTitle  => isEn ? 'Achievements'           : 'Bảng thành tích';
  String get categoryStreak     => isEn ? 'Streak'                 : 'Chuỗi ngày';
  String get categoryBadge      => isEn ? 'By Theme'               : 'Theo chủ đề';
  String get categoryLevel      => isEn ? 'Level'                  : 'Cấp độ';
  String get categorySpecial    => isEn ? 'Special'                : 'Đặc biệt';
  String get noBadgesYet        => isEn ? 'No badges yet'          : 'Chưa có huy hiệu nào';
  String get earnBadgeHint      => isEn ? 'Complete tasks to earn badges!' : 'Hoàn thành nhiệm vụ để nhận huy hiệu!';
  String get holdToChange       => isEn ? 'Hold to change'         : 'Giữ để đổi';
  String get unlocked           => isEn ? '✅ Unlocked'            : '✅ Đã đạt được';
  String get locked             => isEn ? '🔒 Locked'              : '🔒 Chưa đạt được';
  String get resetEmoji         => isEn ? 'Reset'                  : 'Đặt lại';
  String achievementCount(int earned, int total) =>
      isEn ? '$earned / $total achievements' : '$earned / $total thành tích';
  String changeEmojiTitle(String name) =>
      isEn ? 'Change "$name" icon' : 'Đổi hình ảnh "$name"';
  String get changeEmojiInstruction => isEn ? 'Enter new emoji (1 character):' : 'Nhập emoji mới (1 ký tự):';
  String defaultEmojiLabel(String emoji) => isEn ? 'Default: $emoji' : 'Mặc định: $emoji';

  // ── Child Learn ───────────────────────────────────────────────────────────
  String get childLearnTitle   => isEn ? 'Learning Corner 📚' : 'Góc học của con 📚';
  String get filterAll         => isEn ? 'All'               : 'Tất cả';
  String get statusCompleted   => isEn ? '✅ Completed'       : '✅ Hoàn thành';
  String get statusNotStarted  => isEn ? '▶ Not started'     : '▶ Chưa học';
  String lessonProgress(int done, int total) =>
      isEn ? '$done/$total lessons completed' : '$done/$total bài đã hoàn thành';

  // ── Parent Dashboard ──────────────────────────────────────────────────────
  String get defaultBonding    => isEn ? 'Your child did great today!'   : 'Hôm nay con đã làm rất tốt!';
  String get thisWeek          => isEn ? 'This Week'                     : 'Tuần này';
  String get noTasksThisWeek   => isEn ? 'Child completed nothing this week' : 'Con chưa hoàn thành việc nào tuần này';
  String get reviewNow         => isEn ? 'Review Now'                   : 'Duyệt ngay';
  String get reviewBtn         => isEn ? 'Review'                       : 'Duyệt';
  String get assignTask        => isEn ? 'Assign Task'                  : 'Giao việc';
  String get allTasksSection   => isEn ? 'All Tasks'                    : 'Tất cả nhiệm vụ';
  String get noTasksTitle      => isEn ? 'No tasks yet'                 : 'Chưa có nhiệm vụ nào';
  String get noTasksSuggestion => isEn ? 'Tap "Assign Task" to start'   : 'Nhấn "Giao việc" để bắt đầu';
  String get completedSection  => isEn ? '✅ Completed'                  : '✅ Đã hoàn thành';
  String get templateHint      => isEn ? 'Tap a task to save as template ⭐' : 'Nhấn vào task để lưu làm mẫu ⭐';
  String get childWantsBuy     => isEn ? 'Child Wants to Buy'           : 'Con muốn mua';
  String get waitingYourApproval => isEn ? 'Has enough coins, waiting for your approval' : 'Con đã tích đủ xu, đang chờ bạn duyệt';
  String get tabMemories       => isEn ? 'Memories'                     : 'Kỷ niệm';
  String get tabSettings       => 'Settings';
  String moreTasksMemory(int n) => isEn ? '+ $n more tasks in Memory Lane' : '+ $n task khác trong Memory Lane';
  String mostCategory(String cat) => isEn ? 'Most: $cat' : 'Nhiều nhất: $cat';

  // ── Parent Task Detail ────────────────────────────────────────────────────
  String get taskDescSection   => isEn ? 'Task Description'            : 'Mô tả nhiệm vụ';
  String get approvedStatus    => isEn ? 'Approved!'                   : 'Đã duyệt!';
  String get coinsAdded        => isEn ? "Coins added to child's account" : 'Xu đã được cộng vào tài khoản của con';
  String get savedTemplate     => isEn ? 'Saved as template'           : 'Đã lưu làm mẫu';
  String get saveTemplate      => isEn ? 'Save as template'            : 'Lưu làm mẫu';
  String get rejectedStatus    => isEn ? 'Rejected'                    : 'Đã từ chối';
  String get redoMsg           => isEn ? 'Child needs to redo and resubmit' : 'Con cần làm lại và nộp lần nữa';
  String get pendingStatus     => isEn ? 'Waiting for child'           : 'Chờ con hoàn thành';
  String get pendingMsg        => isEn ? 'Task assigned, waiting for child to submit proof' : 'Nhiệm vụ đã được giao, chờ con nộp bằng chứng';
  String get proofSection      => isEn ? 'Proof from child'            : 'Bằng chứng từ con';
  String get noProof           => isEn ? 'Child has not submitted proof yet' : 'Con chưa nộp ảnh bằng chứng';
  String get praiseTitle       => isEn ? '💬 Send praise to child'     : '💬 Gửi lời khen cho con';
  String get praiseSub         => isEn ? "Praise will appear on child's screen" : 'Lời khen sẽ xuất hiện trên màn hình của con';
  String get praiseHint        => isEn ? 'E.g: You did great! I am so proud!' : 'VD: Con đã làm rất tốt! Bố/Mẹ rất tự hào!';
  String get praiseSent        => isEn ? '✅ Praise sent!'             : '✅ Đã gửi lời khen!';
  String get rejectTaskTitle   => isEn ? '❌ Reject Task'              : '❌ Từ chối nhiệm vụ';
  String get rejectReason      => isEn ? 'Enter rejection reason (optional):' : 'Nhập lý do từ chối (tùy chọn):';
  String get rejectReasonHint  => isEn ? 'E.g: Please redo more carefully...' : 'VD: Con cần làm kỹ hơn...';
  String get wellDone          => isEn ? 'Well done!'                  : 'Tuyệt vời!';
  String get streakBadgeMsg    => isEn ? 'Great habit streak! 🎊'      : 'Con đã duy trì thói quen tốt! 🎊';
  String rejectedNoReason()    => isEn ? '❌ Rejected. Child needs to redo.' : '❌ Đã từ chối. Con sẽ cần làm lại.';
  String rejectedWithReason(String r) => isEn ? '❌ Rejected: $r' : '❌ Từ chối: $r';
  String approvalMsg(int coins, String name) =>
      isEn ? 'Approved and added $coins coins for $name! 🎉' : 'Đã duyệt và cộng $coins Xu cho $name! 🎉';
  String sendPraiseTo(String name) => isEn ? 'Send praise to $name' : 'Gửi lời khen cho $name';
  String approveCoins(int coins)   => isEn ? 'Approve +$coins Coins' : 'Duyệt +$coins Xu';
  String submittedAt(String time, String date) =>
      isEn ? 'Submitted at $time on $date' : 'Đã nộp lúc $time ngày $date';

  // ── Parent Create Task ────────────────────────────────────────────────────
  String get createTaskTitle    => isEn ? 'New Task!'                      : 'Nhiệm vụ mới!';
  String get createTaskSub      => isEn ? 'What task to assign today?'     : 'Hôm nay giao việc gì cho con?';
  String get savedTemplates     => isEn ? '⭐ Active Tasks'                 : '⭐ Nhiệm vụ đang giao';
  String get quickIdeas         => isEn ? 'Quick Ideas'                    : 'Ý tưởng nhanh';
  String get customTask         => isEn ? 'Create Custom Task'             : 'Tạo nhiệm vụ tùy chỉnh';
  String get taskNameLabel      => isEn ? 'Task name'                      : 'Tên nhiệm vụ';
  String get taskNameHint       => isEn ? 'E.g: Clean bedroom'             : 'VD: Quét dọn phòng ngủ';
  String get descriptionLabel   => isEn ? 'Description (Optional)'         : 'Mô tả (Tùy chọn)';
  String get descriptionHint    => isEn ? 'Additional instructions...'     : 'Hướng dẫn thêm cho con...';
  String get categorySection    => isEn ? 'Category'                       : 'Danh mục';
  String get rewardLabel        => 'REWARD';
  String get createTaskBtn      => isEn ? 'Assign Task'                    : 'Giao việc';
  String get taskCreatedTitle   => isEn ? 'Task Assigned!'                 : 'Đã giao việc!';
  String taskCreatedMsg(String name, int coins) =>
      isEn ? '$name will be notified right away!\n\nReward: $coins Coins 🪙'
           : '$name sẽ nhận được thông báo ngay!\n\nPhần thưởng: $coins Xu 🪙';

  // ── Parent Memory Lane ────────────────────────────────────────────────────
  String get memoriesTitle      => isEn ? 'Memories'                        : 'Kỷ niệm của con';
  String get memoriesSub        => isEn ? "Look back at memorable moments in your child's journey."
                                        : 'Nhìn lại những khoảnh khắc đáng nhớ trong hành trình của con.';
  String get exportVideoBtn     => isEn ? 'Export Memory Video 2026'        : 'Xuất video kỷ niệm 2026';
  String get shareMemoriesTitle => isEn ? "Child's Journey"                 : 'Hành trình của con';
  String get shareInstructions  => isEn ? 'Screenshot this page to save and share your child\'s financial journey with family! 🌱'
                                        : 'Chụp màn hình trang này để lưu lại và chia sẻ hành trình tài chính với gia đình! 🌱';
  String get statMemories       => isEn ? 'Memories'   : 'Kỷ niệm';
  String get statTasksDone      => isEn ? 'Tasks'      : 'Nhiệm vụ';
  String get statCoinsEarned    => isEn ? 'Coins'      : 'Xu tích lũy';
  String get noProofImage       => isEn ? 'No proof image' : 'Không có ảnh bằng chứng';
  String get statusApproved     => isEn ? '✅ Approved'    : '✅ Đã duyệt';
  String noMemoriesTitle()      => isEn ? 'No memories yet'    : 'Chưa có kỷ niệm nào';
  String noMemoriesSub(String name) =>
      isEn ? 'Approve $name\'s first task\nto create a memory!'
           : 'Duyệt nhiệm vụ đầu tiên cho $name\nđể tạo kỷ niệm!';
  String journeyOf(String name) => isEn ? '$name\'s Journey' : 'Hành trình của $name';
  String shareMsg(String name)  =>
      isEn ? 'Screenshot this page to save and share $name\'s financial journey with family! 🌱'
           : 'Chụp màn hình trang này để lưu lại và chia sẻ hành trình tài chính của $name với gia đình! 🌱';

  // ── Parent Settings ───────────────────────────────────────────────────────
  String get sectionChildProfile => isEn ? '👦 Child Profile'     : '👦 Child Profile';
  String get childNameTitle      => isEn ? "Child's Name"         : 'Tên con';
  String get notSetYet           => isEn ? 'Not set'              : 'Chưa đặt tên';
  String get ageTitle            => isEn ? 'Age'                  : 'Tuổi';
  String get sectionAppSettings  => isEn ? '⚙️ App Settings'      : '⚙️ App Settings';
  String get notificationsTitle  => isEn ? 'Notifications'        : 'Thông báo';
  String get notificationsSub    => isEn ? 'Daily reminders'      : 'Nhắc nhở hàng ngày';
  String get languageTitle       => isEn ? 'Language'             : 'Ngôn ngữ';
  String get currentLanguage     => isEn ? 'English'              : 'Tiếng Việt';
  String get themeTitle          => isEn ? 'Theme'                : 'Giao diện';
  String get themeLight          => isEn ? 'Light'                : 'Sáng';
  String get sectionInfo         => isEn ? 'ℹ️ Info'              : 'ℹ️ Info';
  String get helpTitle           => isEn ? 'Help & Support'       : 'Help & Support';
  String get helpSub             => isEn ? 'User guide'           : 'Hướng dẫn sử dụng';
  String get aboutSub            => isEn ? 'Version 1.0.0 · EXE201 Demo' : 'Version 1.0.0 · EXE201 Demo';
  String get editDisplayName     => isEn ? '✏️ Edit display name' : '✏️ Đổi tên hiển thị';
  String get yourNameHint        => isEn ? 'Your name'            : 'Tên của bạn';
  String get editChildNameDialog => isEn ? "✏️ Edit child's name" : '✏️ Đổi tên con';
  String get editAgeDialog       => isEn ? '🎂 Edit age'          : '🎂 Đổi tuổi con';
  String get ageSuffix           => isEn ? 'years old'            : 'tuổi';
  String get languageDialogTitle => isEn ? '🌐 Language'          : '🌐 Ngôn ngữ';
  String get themeDialogTitle    => isEn ? '🎨 Theme'             : '🎨 Giao diện';
  String get themeDark           => isEn ? 'Dark'                 : 'Tối';
  String get themeSystem         => isEn ? 'System'               : 'Theo hệ thống';
  String get helpDialogTitle     => isEn ? '❓ User Guide'         : '❓ Hướng dẫn sử dụng';
  String get contactTitle        => isEn ? 'Contact Support'      : 'Liên hệ hỗ trợ';
  String get aboutDescription    => isEn
      ? 'EdTech/Family-Tech platform for financial education for children aged 6–12.\n\nEXE201 Project · FPT University'
      : 'Nền tảng EdTech/Family-Tech giáo dục tài chính cho trẻ 6–12 tuổi.\n\nEXE201 Project · FPT University';

  String ageDisplay(int age)     => isEn ? '$age years old' : '$age tuổi';
  String get addBtn              => isEn ? 'Add'             : 'Thêm';
  String get deletePinLabel      => isEn ? 'Delete PIN'      : 'Xóa mã PIN';
  String get deletePinSuccess    => isEn ? 'PIN deleted ✓'   : 'Đã xóa mã PIN ✓';
  String setPinSuccess(String name) => isEn ? 'PIN set for $name ✓' : 'Đã đặt mã PIN cho $name ✓';
  String get moodToday           => isEn ? 'Mood today'       : 'Tâm trạng hôm nay';
  String get aiSelfieAnalysis    => isEn ? 'AI analyzes emotion via selfie' : 'AI phân tích cảm xúc qua ảnh selfie';
  String get whyUseThis          => isEn ? 'Why use this? 💡' : 'Vì sao nên dùng? 💡';
  String get moodTodayPrefix     => isEn ? 'Mood today: '    : 'Tâm trạng hôm nay: ';
  String get refresh             => isEn ? '↺ Refresh'       : '↺ Làm mới';
  String get faceNotDetected     => isEn ? 'Face not detected — try better lighting 💡' : 'Không nhận diện được khuôn mặt — thử lại với ánh sáng tốt hơn nhé 💡';
  String get reviewAndApprove    => isEn ? 'Review & Approve' : 'Đánh giá & Duyệt';
  String get qualityRating       => isEn ? 'Rate completion quality' : 'Đánh giá chất lượng hoàn thành';
  String get qualityRatingSub    => isEn ? 'Choose level to calculate reward' : 'Chọn mức độ để tính xu thưởng';
  String approveWithCoins(int n) => isEn ? 'Approve & Send 🪙 $n coins' : 'Duyệt & Gửi 🪙 $n xu';
  String get cancelAutoTitle     => isEn ? 'Cancel auto-approve?' : 'Huỷ duyệt tự động?';
  String get nah                 => isEn ? 'No'               : 'Thôi';
  String get cancelledAutoMsg    => isEn ? 'Auto-approve cancelled — child needs to resubmit' : 'Đã huỷ duyệt — con cần nộp lại đúng cách';
  String get cancelAutoBtn       => isEn ? 'Cancel approve'   : 'Huỷ duyệt';
  String get pauseTaskLabel      => isEn ? 'Pause'            : 'Tạm dừng';
  String get deleteTaskLabel     => isEn ? 'Delete'           : 'Xóa hẳn';
  String get pauseTaskTitle      => isEn ? 'Pause task?'      : 'Tạm dừng nhiệm vụ?';
  String get deleteTaskTitle     => isEn ? 'Delete task?'     : 'Xóa nhiệm vụ?';
  String get autoApproveChip     => isEn ? '⚡ Auto'          : '⚡ Tự duyệt';
  String get startTask           => isEn ? 'Start!'           : 'Bắt đầu làm!';
  String get skipTask            => isEn ? 'Skip task'        : 'Bỏ task';
  String get notApprovedYet      => isEn ? 'Parent not approved yet' : 'Ba/Mẹ chưa duyệt';
  String get reasonPrefix        => isEn ? 'Reason: '         : 'Lý do: ';
  String get resubmit            => isEn ? 'Resubmit'         : 'Nộp lại';
  String get skipTaskTitle       => isEn ? 'Skip this task?'  : 'Bỏ task này?';
  String penaltyAmount(int n)    => isEn ? '$n% reward deducted' : '$n% phần thưởng bị trừ';
  String get confirmSkip         => isEn ? 'Confirm skip'     : 'Xác nhận bỏ task';
  String get keepTask            => isEn ? 'Keep task'        : 'Giữ lại task';
  String get noMemoriesToExport  => isEn ? 'No memories to export.' : 'Chưa có kỷ niệm nào để xuất.';
  String get pinMismatch         => isEn ? 'PINs do not match. Try again.' : 'Mã PIN không khớp. Thử lại.';
  String get confirmPinTitle     => isEn ? 'Confirm PIN'            : 'Xác nhận mã PIN';
  String get reenterPin          => isEn ? 'Re-enter PIN to confirm' : 'Nhập lại mã PIN để xác nhận';
  String get enterPin4           => isEn ? 'Enter 4 digits'         : 'Nhập 4 chữ số';
  String setPinFor(String name)  => isEn ? 'Set PIN for $name'      : 'Đặt mã PIN cho $name';
  String get hasPinLabel         => isEn ? 'PIN set 🔐'             : 'Đã đặt mã PIN 🔐';
  String get noPinLabel          => isEn ? 'No PIN set'             : 'Chưa có mã PIN';
  String get changePinLabel      => isEn ? 'Change PIN'             : 'Đổi mã PIN';
  String get setPinLabel         => isEn ? 'Set PIN'                : 'Đặt mã PIN';

  // FAQ
  String get faq1q => isEn ? 'How to create tasks for my child?' : 'Cách tạo nhiệm vụ cho con?';
  String get faq1a => isEn
      ? 'Go to the Tasks tab → tap + button → fill in name, description, category and coin reward → tap Assign Task.'
      : 'Vào tab "Nhiệm vụ" → nhấn nút + góc phải → điền tên, mô tả, danh mục và số xu thưởng → nhấn Tạo nhiệm vụ.';
  String get faq2q => isEn ? 'When does my child receive coins?' : 'Con nhận xu khi nào?';
  String get faq2a => isEn
      ? 'Coins are added right after you approve the task. Child submits proof → you check → tap Approve.'
      : 'Xu được cộng ngay sau khi bạn duyệt nhiệm vụ của con. Con nộp bằng chứng → bạn kiểm tra → nhấn Duyệt.';
  String get faq3q => isEn ? 'How do the jars work?' : 'Hũ tiền hoạt động như thế nào?';
  String get faq3a => isEn
      ? 'When your child earns coins: 40% to Save, 40% to Spend, 20% to Share. Teaches money management from an early age.'
      : 'Mỗi khi con nhận xu, hệ thống tự chia: 40% vào hũ Tiết kiệm, 40% hũ Tiêu dùng, 20% hũ Sẻ chia. Giúp con học quản lý tài chính từ sớm.';
  String get faq4q => isEn ? 'What is the Dream Jar?' : 'Ước mơ là gì?';
  String get faq4a => isEn
      ? 'Your child sets a goal to buy a favorite item. The progress bar updates as coins are earned.'
      : 'Con đặt mục tiêu mua đồ vật yêu thích. Hệ thống hiện thanh tiến độ dựa trên xu đã tích lũy, giúp con có động lực hoàn thành nhiệm vụ.';
  String get faq5q => isEn ? 'How are badges awarded?' : 'Huy hiệu được trao như thế nào?';
  String get faq5a => isEn
      ? 'Badges are automatically awarded at milestones: 5/15 tasks by theme, 3/7/14/30 day streaks, or reaching a new level.'
      : 'Huy hiệu trao tự động khi con đạt mốc: hoàn thành 5/15 nhiệm vụ theo chủ đề, giữ streak 3/7/14/30 ngày, hoặc lên level mới.';
  String get faq6q => isEn ? 'How to reset my password?' : 'Làm sao đặt lại mật khẩu?';
  String get faq6a => isEn
      ? 'On the login screen → tap "Forgot password?" → enter email → check inbox and follow instructions.'
      : 'Ở màn hình đăng nhập → nhấn "Quên mật khẩu?" → nhập email → kiểm tra hộp thư và làm theo hướng dẫn.';

  // ── Parent Learn ──────────────────────────────────────────────────────────
  String get parentLearnTitle => isEn ? 'Parent Learning Corner 🎓' : 'Góc học dành cho bố mẹ 🎓';
  String get parentLearnIntro => isEn ? 'Build financial habits' : 'Nuôi dưỡng thói quen tài chính';
  String get parentLearnSub   => isEn ? 'Lessons to help you guide your child more effectively.' : 'Những bài học giúp bạn đồng hành cùng con hiệu quả hơn.';

  // ── Video Lesson ──────────────────────────────────────────────────────────
  String get quizTitle         => isEn ? 'Question!'              : 'Câu hỏi!';
  String get readQuestion      => isEn ? 'Read question'          : 'Đọc câu hỏi';
  String get noVietnameseVoice => isEn ? 'No Vietnamese voice'    : 'Chưa có giọng Tiếng Việt';
  String get ttsWarning        => isEn ? 'No Vietnamese voice — tap to see setup instructions' : 'Chưa có giọng Tiếng Việt — nhấn để xem cách cài';
  String get ttsDialogTitle    => isEn ? 'Install Vietnamese Voice' : 'Cài giọng Tiếng Việt';
  String get ttsInstructions   => isEn
      ? 'Android:\nSettings → General management → Language & Input → Text-to-speech → Google TTS → Install Vietnamese\n\niOS:\nSettings → Accessibility → Spoken Content → Voices → Vietnamese'
      : 'Android:\nSettings → General management → Language & Input → Text-to-speech → Google TTS → Settings → Install voice data → Vietnamese\n\niOS:\nSettings → Accessibility → Spoken Content → Voices → Vietnamese';
  String get continueVideo     => isEn ? 'Continue ▶'            : 'Tiếp tục xem ▶';
  String get lessonCompleted   => isEn ? 'Lesson Complete! 🎉'    : 'Hoàn thành bài học! 🎉';
  String get xpEarned          => isEn ? '+10 XP added to your account!' : '+10 XP đã được cộng vào tài khoản!';
  String get earnXpHint        => isEn ? '💡 Complete the lesson to earn +10 XP!' : '💡 Hoàn thành bài học để nhận +10 XP!';

  // ── Micro Lesson ──────────────────────────────────────────────────────────
  String get lessonCompleteTitle => isEn ? 'Done! 🎉'             : 'Hoàn thành rồi! 🎉';
  String get todayLesson         => isEn ? '💡 Today\'s lesson'   : '💡 Bài học hôm nay';
  String get howDoYouFeel        => isEn ? 'How do you feel?'     : 'Con cảm thấy thế nào?';
  String get moodHappy           => isEn ? 'Happy'                : 'Vui';
  String get moodNeutral         => isEn ? 'Okay'                 : 'Bình thường';
  String get moodTired           => isEn ? 'Tired'                : 'Mệt';

  // ── AI Chat ───────────────────────────────────────────────────────────────
  String get aiOnline           => isEn ? 'Online'               : 'Đang hoạt động';
  String get aiInputHint        => isEn ? 'Message AI...'        : 'Nhắn tin với AI...';
  String get aiQuickTasks       => isEn ? '📋 Today\'s tasks'    : '📋 Nhiệm vụ hôm nay';
  String get aiQuickCoins       => isEn ? '💰 My coins'          : '💰 Số xu của con';
  String get aiQuickDreams      => isEn ? '🧱 Dreams'            : '🧱 Ước mơ';
  String get aiQuickMessage     => isEn ? '💌 Parent\'s message' : '💌 Lời nhắn bố';
  String aiGreeting(String name) => isEn
      ? 'Hello $name! I\'m GrowWise AI 🌱\nI can help you:\n• View today\'s tasks\n• Check coins and jars\n• Track your dreams\n• Read parent\'s messages\n\nWhat would you like to know?'
      : 'Xin chào $name! Mình là trợ lý AI của GrowWise 🌱\nMình có thể giúp con:\n• Xem nhiệm vụ hôm nay\n• Kiểm tra số xu và hũ tiền\n• Theo dõi ước mơ\n• Nghe lời nhắn từ bố/mẹ\n\nCon muốn hỏi gì không?';
}
