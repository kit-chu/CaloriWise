import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/text_style.dart';
import '../services/data_cache_service.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;

  // Animation controllers for smooth page transitions
  late AnimationController _tabAnimationController;
  late Animation<double> _tabAnimation;
  late AnimationController _pageTransitionController;

  // Controllers for manual entry
  final _foodNameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _searchController = TextEditingController();

  // Basic info
  DateTime _selectedDate = DateTime.now();
  String _selectedMealType = 'มื้อเช้า';

  // AI Analysis
  bool _isAnalyzing = false;
  bool _analysisComplete = false;

  final List<String> _mealTypes = ['มื้อเช้า', 'มื้อกลางวัน', 'มื้อเย็น', 'ของว่าง'];

  // Data caching service
  final DataCacheService _cacheService = DataCacheService();

  // Loading states
  bool _isLoadingPopularFoods = false;
  bool _isLoadingFavorites = false;

  // Popular food database with caching
  List<Map<String, dynamic>> _popularFoods = [];
  List<Map<String, dynamic>> _favoriteFoods = [];

  // Mock data for dates with food entries
  Set<DateTime> _datesWithEntries = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Initialize animation controllers
    _tabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _tabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _tabAnimationController,
      curve: Curves.easeInOut,
    ));

    _pageTransitionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _loadCachedData();
    _generateMockDatesWithEntries();
  }

  void _generateMockDatesWithEntries() {
    final now = DateTime.now();
    _datesWithEntries = {
      DateTime(now.year, now.month, now.day - 2),
      DateTime(now.year, now.month, now.day - 1),
      DateTime(now.year, now.month, now.day),
      DateTime(now.year, now.month, now.day + 1),
    };
  }

  // Load cached data on screen init
  void _loadCachedData() {
    _loadPopularFoodsWithCache();
    _loadFavoriteFoodsWithCache();
  }

  Future<void> _loadPopularFoodsWithCache() async {
    if (_isLoadingPopularFoods) return;

    // Check cache first
    final cachedFoods = _cacheService.getCachedPopularFoods();
    if (cachedFoods != null) {
      setState(() {
        _popularFoods = cachedFoods;
      });
      return;
    }

    // Load from "server"
    setState(() => _isLoadingPopularFoods = true);

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _generatePopularFoods();
      _cacheService.setCachedPopularFoods(_popularFoods);
    } finally {
      setState(() => _isLoadingPopularFoods = false);
    }
  }

  Future<void> _loadFavoriteFoodsWithCache() async {
    if (_isLoadingFavorites) return;

    // Check cache first
    final cachedFavorites = _cacheService.getCachedFavoriteFoods();
    if (cachedFavorites != null) {
      setState(() {
        _favoriteFoods = cachedFavorites;
      });
      return;
    }

    // Load from "server"
    setState(() => _isLoadingFavorites = true);

    try {
      await Future.delayed(const Duration(milliseconds: 200));
      _generateFavoriteFoods();
      _cacheService.setCachedFavoriteFoods(_favoriteFoods);
    } finally {
      setState(() => _isLoadingFavorites = false);
    }
  }

  void _generatePopularFoods() {
    _popularFoods = [
      {'name': 'ข้าวผัด', 'calories': 350, 'icon': '🍳', 'category': 'อาหารไทย'},
      {'name': 'ผัดไทย', 'calories': 300, 'icon': '🍜', 'category': 'อาหารไทย'},
      {'name': 'ส้มตำ', 'calories': 120, 'icon': '🥗', 'category': 'อาหารไทย'},
      {'name': 'ต้มยำกุ้ง', 'calories': 180, 'icon': '🍲', 'category': 'อาหารไทย'},
      {'name': 'แกงเขียวหวาน', 'calories': 250, 'icon': '🍛', 'category': 'อาหารไทย'},

      {'name': 'แฮมเบอร์เกอร์', 'calories': 540, 'icon': '🍔', 'category': 'ฟาสต์ฟู้ด'},
      {'name': 'พิซซ่า (1 ชิ้น)', 'calories': 280, 'icon': '🍕', 'category': 'ฟาสต์ฟู้ด'},
      {'name': 'เฟรนช์ฟรายส์', 'calories': 320, 'icon': '🍟', 'category': 'ฟาสต์ฟู้ด'},

      {'name': 'สลัดผัก', 'calories': 150, 'icon': '🥗', 'category': 'เพื่อสุขภาพ'},
      {'name': 'โยเกิร์ต', 'calories': 100, 'icon': '🥛', 'category': 'เพื่อสุขภาพ'},
      {'name': 'กล้วย', 'calories': 90, 'icon': '🍌', 'category': 'ผลไม้'},
      {'name': 'แอปเปิ้ล', 'calories': 80, 'icon': '🍎', 'category': 'ผลไม้'},
    ];
  }

  void _generateFavoriteFoods() {
    _favoriteFoods = [
      {'name': 'ข้าวผัดแม่ทำ', 'calories': 380, 'icon': '🍳'},
      {'name': 'ส้มตำบ้านๆ', 'calories': 150, 'icon': '🥗'},
      {'name': 'กาแฟเย็น', 'calories': 120, 'icon': '☕'},
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    _foodNameController.dispose();
    _caloriesController.dispose();
    _searchController.dispose();
    _tabAnimationController.dispose();
    _pageTransitionController.dispose();
    super.dispose();
  }

  String _getMealTypeInThai() {
    return _selectedMealType;
  }

  String _getDateDisplayText() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    if (selected == today) {
      return 'วันนี้';
    } else if (selected == today.subtract(const Duration(days: 1))) {
      return 'เมื่อวาน';
    } else if (selected == today.add(const Duration(days: 1))) {
      return 'พรุ่งนี้';
    } else {
      return '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Hide keyboard when tapping outside
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            // Top Bar พร้อมปุ่มย้อนกลับ
            _buildTopBar(),
            // Bottom Navigation Style Tabs
            _buildBottomNavTabs(),
            // Page Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const ClampingScrollPhysics(),
                onPageChanged: (index) {
                  // Hide keyboard when changing tabs
                  FocusScope.of(context).unfocus();
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildQuickAddPage(),
                  _buildAIPage(),
                  _buildManualPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Row(
            children: [
              // ปุ่มย้อนกลับ
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new),
                  color: AppTheme.primaryPurple,
                  iconSize: 18,
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(width: 16),
              // Title
              Expanded(
                child: Text(
                  'เพิ่มอาหาร',
                  style: AppTextStyle.titleLarge(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              // ปุ่มค้นหา
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  onPressed: () {
                    // Show search functionality
                  },
                  icon: const Icon(Icons.search),
                  color: AppTheme.primaryPurple,
                  iconSize: 18,
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImprovedHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryPurple, AppTheme.primaryPurple.withAlpha(204)],
        ),
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            children: [
              // Date and Current View Info
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'เพิ่มอาหารสำหรับ',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_getDateDisplayText()} • ${_getMealTypeInThai()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Compact Date Button
                  InkWell(
                    onTap: _showImprovedDatePicker,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'เปลี่ยน',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Meal Type Chips - เล็กลง
              SizedBox(
                height: 32,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _mealTypes.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final type = _mealTypes[index];
                    final isSelected = type == _selectedMealType;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedMealType = type),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          type,
                          style: TextStyle(
                            color: isSelected ? AppTheme.primaryPurple : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildNavTab(0, Icons.flash_on, 'เลือกด่วน'),
          _buildNavTab(1, Icons.camera_alt, 'ถ่ายรูป'),
          _buildNavTab(2, Icons.edit, 'กรอกเอง'),
        ],
      ),
    );
  }

  Widget _buildNavTab(int index, IconData icon, String label) {
    final isSelected = _currentPage == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppTheme.primaryPurple : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppTheme.primaryPurple : Colors.grey[600],
                size: 24,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppTheme.primaryPurple : Colors.grey[600],
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Improved Date Picker
  void _showImprovedDatePicker() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: AppTheme.primaryPurple, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'เลือกวันที่',
                        style: AppTextStyle.titleMedium(context).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      iconSize: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Current selection info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'วันที่เลือก',
                        style: TextStyle(
                          color: AppTheme.primaryPurple,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_getDateDisplayText()} (${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year})',
                        style: TextStyle(
                          color: AppTheme.primaryPurple,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Quick date selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'เลือกวันที่',
                      style: AppTextStyle.titleSmall(context).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._buildQuickDateOptions(),
                  ],
                ),
                const SizedBox(height: 20),

                // Custom date picker button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 30)),
                        lastDate: DateTime.now().add(const Duration(days: 7)),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                    icon: const Icon(Icons.date_range),
                    label: const Text('เลือกวันที่อื่น'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryPurple,
                      side: BorderSide(color: AppTheme.primaryPurple),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildQuickDateOptions() {
    final now = DateTime.now();
    final options = [
      {
        'date': now.subtract(const Duration(days: 1)),
        'label': 'เมื่อวาน',
        'subtitle': '${now.subtract(const Duration(days: 1)).day}/${now.subtract(const Duration(days: 1)).month}',
      },
      {
        'date': now,
        'label': 'วันนี้',
        'subtitle': '${now.day}/${now.month}',
      },
      {
        'date': now.add(const Duration(days: 1)),
        'label': 'พรุ่งนี้',
        'subtitle': '${now.add(const Duration(days: 1)).day}/${now.add(const Duration(days: 1)).month}',
      },
    ];

    return options.map((option) {
      final date = option['date'] as DateTime;
      final label = option['label'] as String;
      final subtitle = option['subtitle'] as String;
      final isSelected = DateTime(date.year, date.month, date.day) ==
          DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      final hasEntries = _datesWithEntries.contains(DateTime(date.year, date.month, date.day));

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: () {
            setState(() => _selectedDate = date);
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryPurple.withOpacity(0.1) : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppTheme.primaryPurple : Colors.grey[200]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: isSelected ? AppTheme.primaryPurple : Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              color: isSelected ? AppTheme.primaryPurple : Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (hasEntries) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      if (hasEntries)
                        Text(
                          'มีรายการอาหาร',
                          style: TextStyle(
                            color: Colors.green[600],
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: AppTheme.primaryPurple,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  // Page 1: Quick Add
  Widget _buildQuickAddPage() {
    return Column(
      children: [
        // Show improved header only in first tab
        _buildImprovedHeader(),
        _buildSearchSection(),
        Expanded(
          child: _buildCategoriesAndResults(),
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {});
              },
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'ค้นหาอาหาร เช่น "ข้าวผัด", "ไก่ทอด"...',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
                prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 24),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[600]),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),

          // Quick Search Suggestions
          if (_searchController.text.isEmpty) ...[
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text(
                    'ค้นหาด่วน: ',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ...[
                    'ข้าวผัด',
                    'ไก่ทอด',
                    'ส้มตำ',
                    'พิซซ่า',
                    'สลัด'
                  ].map((term) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        _searchController.text = term;
                        setState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppTheme.primaryPurple.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          term,
                          style: TextStyle(
                            color: AppTheme.primaryPurple,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoriesAndResults() {
    // Check if searching
    if (_searchController.text.isNotEmpty) {
      return _buildSearchResults();
    }

    // Show categories and favorites
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMyFavorites(),
          const SizedBox(height: 32),
          _buildFoodCategories(),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final searchTerm = _searchController.text.toLowerCase();
    final results = _popularFoods.where((food) {
      return food['name'].toString().toLowerCase().contains(searchTerm);
    }).toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            border: Border(
              bottom: BorderSide(color: Colors.blue[100]!),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.blue[600], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ผลการค้นหา "${_searchController.text}" (${results.length} รายการ)',
                  style: AppTextStyle.titleSmall(context).copyWith(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: results.isEmpty
              ? _buildNoSearchResults()
              : ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: results.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final food = results[index];
              return _buildSearchResultCard(food);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              'ไม่พบอาหารที่ค้นหา',
              style: AppTextStyle.titleMedium(context).copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'ลองค้นหาด้วยคำอื่น หรือเพิ่มอาหารใหม่ในแท็บ "กรอกเอง"',
              style: AppTextStyle.bodyMedium(context).copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () {
                _pageController.animateToPage(2,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut
                );
              },
              icon: const Icon(Icons.add, size: 20),
              label: const Text('เพิ่มอาหารใหม่', style: TextStyle(fontSize: 16)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryPurple,
                side: BorderSide(color: AppTheme.primaryPurple),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultCard(Map<String, dynamic> food) {
    return GestureDetector(
      onTap: () => _showQuickAddConfirmation(food),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  food['icon'],
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food['name'],
                    style: AppTextStyle.bodyLarge(context).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    food['category'],
                    style: AppTextStyle.bodyMedium(context).copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '${food['calories']} kcal',
                style: AppTextStyle.bodyMedium(context).copyWith(
                  color: Colors.orange[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.add_circle_outline,
              color: AppTheme.primaryPurple,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyFavorites() {
    final myFavorites = [
      {'name': 'ข้าวผัดแม่ทำ', 'calories': 380, 'icon': '🍳'},
      {'name': 'ส้มตำบ้านๆ', 'calories': 150, 'icon': '🥗'},
      {'name': 'กาแฟเย็น', 'calories': 120, 'icon': '☕'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.bookmark, color: AppTheme.primaryPurple, size: 20),
            const SizedBox(width: 8),
            Text(
              'เมนูประจำ',
              style: AppTextStyle.titleMedium(context).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _showManageFavorites,
              child: Text(
                'จัดการ',
                style: TextStyle(
                  color: AppTheme.primaryPurple,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: myFavorites.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final food = myFavorites[index];
              return _buildFavoriteCard(food);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteCard(Map<String, dynamic> food) {
    return GestureDetector(
      onTap: () => _showQuickAddConfirmation(food),
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryPurple.withOpacity(0.1),
              AppTheme.primaryPurple.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.2)),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            children: [
              Text(food['icon'], style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 6),
              Text(
                food['name'],
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${food['calories']} kcal',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.primaryPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoodCategories() {
    final categories = _popularFoods
        .map((food) => food['category'] as String)
        .toSet()
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.category, color: AppTheme.primaryPurple, size: 20),
            const SizedBox(width: 8),
            Text(
              'หมวดหมู่อาหาร',
              style: AppTextStyle.titleMedium(context).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...categories.map((category) => _buildCategorySection(category)),
      ],
    );
  }

  Widget _buildCategorySection(String category) {
    final categoryFoods = _popularFoods
        .where((food) => food['category'] == category)
        .toList();

    final categoryIcons = {
      'อาหารไทย': '🇹🇭',
      'ฟาสต์ฟู้ด': '🍔',
      'เพื่อสุขภาพ': '🥗',
      'ผลไม้': '🍎',
      'เครื่องดื่ม': '🥤',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                Text(
                  categoryIcons[category] ?? '🍽️',
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category,
                    style: AppTextStyle.titleMedium(context).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${categoryFoods.length}',
                    style: TextStyle(
                      color: AppTheme.primaryPurple,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 8,
              ),
              itemCount: categoryFoods.length,
              itemBuilder: (context, index) {
                final food = categoryFoods[index];
                return _buildFoodCard(food);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodCard(Map<String, dynamic> food) {
    return GestureDetector(
      onTap: () => _showQuickAddConfirmation(food),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Text(food['icon'], style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    food['name'],
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${food['calories']} kcal',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.primaryPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Page 2: AI Camera
  Widget _buildAIPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!_isAnalyzing && !_analysisComplete) ...[
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primaryPurple, width: 4),
                color: AppTheme.primaryPurple.withOpacity(0.1),
              ),
              child: InkWell(
                onTap: _startAIAnalysis,
                borderRadius: BorderRadius.circular(90),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt,
                      size: 60,
                      color: AppTheme.primaryPurple,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'ถ่ายรูป',
                      style: TextStyle(
                        color: AppTheme.primaryPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'AI จะวิเคราะห์และคำนวณแคลอรี่ให้อัตโนมัติ',
              style: AppTextStyle.bodyLarge(context).copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (_isAnalyzing) _buildAnalyzingState(),
          if (_analysisComplete) _buildAIResult(),
        ],
      ),
    );
  }

  Widget _buildAnalyzingState() {
    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
            strokeWidth: 5,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryPurple),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'กำลังวิเคราะห์...',
          style: AppTextStyle.titleLarge(context).copyWith(
            color: AppTheme.primaryPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAIResult() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: const DecorationImage(
              image: NetworkImage('https://picsum.photos/400/300'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'ข้าวผัดกุ้ง',
                style: AppTextStyle.titleLarge(context).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '350 แคลอรี่',
                style: AppTextStyle.titleLarge(context).copyWith(
                  color: AppTheme.primaryPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _confirmAIResult,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'เพิ่มอาหารนี้',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Page 3: Manual Entry
  Widget _buildManualPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildPhotoSection(),
          const SizedBox(height: 20),
          TextField(
            controller: _foodNameController,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              labelText: 'ชื่ออาหาร',
              labelStyle: const TextStyle(fontSize: 16),
              hintText: 'เช่น ข้าวผัดแม่ทำ',
              hintStyle: const TextStyle(fontSize: 16),
              prefixIcon: Icon(Icons.restaurant, color: AppTheme.primaryPurple, size: 24),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _caloriesController,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              labelText: 'แคลอรี่ (kcal)',
              labelStyle: const TextStyle(fontSize: 16),
              prefixIcon: Icon(Icons.local_fire_department, color: Colors.orange, size: 24),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              filled: true,
              fillColor: Colors.orange.withOpacity(0.05),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: ['100', '200', '300', '400', '500'].map((cal) =>
                _buildQuickCalorieChip('$cal kcal')
            ).toList(),
          ),
          const SizedBox(height: 32),
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitManualFood,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'เพิ่มอาหาร',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _saveToFavorites,
                  icon: const Icon(Icons.bookmark_add, size: 20),
                  label: const Text('บันทึกเป็นเมนูประจำ', style: TextStyle(fontSize: 16)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryPurple,
                    side: BorderSide(color: AppTheme.primaryPurple),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(14),
        color: Colors.grey[50],
      ),
      child: InkWell(
        onTap: _takePhoto,
        borderRadius: BorderRadius.circular(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo, size: 36, color: Colors.grey[600]),
            const SizedBox(height: 8),
            Text(
              'ถ่ายรูปอาหาร (ไม่บังคับ)',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickCalorieChip(String text) {
    return ActionChip(
      label: Text(text, style: const TextStyle(fontSize: 14)),
      onPressed: () {
        final calories = text.replaceAll(' kcal', '');
        _caloriesController.text = calories;
      },
      backgroundColor: AppTheme.primaryPurple.withOpacity(0.1),
      labelStyle: TextStyle(
        color: AppTheme.primaryPurple,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  // Helper Methods
  void _showQuickAddConfirmation(Map<String, dynamic> food) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(28),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  food['icon'],
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              food['name'],
              style: AppTextStyle.titleLarge(context).copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_fire_department, color: Colors.orange, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    '${food['calories']} แคลอรี่',
                    style: AppTextStyle.titleMedium(context).copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.schedule, size: 18, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        _selectedMealType,
                        style: AppTextStyle.bodyLarge(context).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        _getDateDisplayText(),
                        style: AppTextStyle.bodyMedium(context).copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.grey[400]!),
                    ),
                    child: Text(
                      'ยกเลิก',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context, true);
                      _showSuccessSnackBar('เพิ่ม ${food['name']} สำเร็จ!');
                    },
                    icon: const Icon(Icons.add_circle, color: Colors.white, size: 22),
                    label: const Text(
                      'เพิ่มอาหารนี้',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPurple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showManageFavorites() {
    _pageController.animateToPage(2, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ใช้แท็บ "กรอกเอง" เพื่อเพิ่มเมนูประจำใหม่'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _startAIAnalysis() {
    setState(() => _isAnalyzing = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _analysisComplete = true;
        });
      }
    });
  }

  void _confirmAIResult() {
    Navigator.pop(context, true);
    _showSuccessSnackBar('เพิ่มข้าวผัดกุ้ง สำเร็จ!');
  }

  void _takePhoto() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ถ่ายรูปสำเร็จ!')),
    );
  }

  void _submitManualFood() {
    if (_foodNameController.text.isNotEmpty && _caloriesController.text.isNotEmpty) {
      Navigator.pop(context, true);
      _showSuccessSnackBar('เพิ่ม ${_foodNameController.text} สำเร็จ!');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณากรอกชื่ออาหารและแคลอรี่'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _saveToFavorites() {
    if (_foodNameController.text.isNotEmpty && _caloriesController.text.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.bookmark_add, color: AppTheme.primaryPurple, size: 24),
              const SizedBox(width: 8),
              const Text('บันทึกเมนูประจำ', style: TextStyle(fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('เมนู: ${_foodNameController.text}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 4),
              Text('แคลอรี่: ${_caloriesController.text} kcal', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              Text(
                'บันทึกเป็นเมนูประจำเพื่อเลือกใช้งานได้ง่ายในครั้งถัดไป',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก', style: TextStyle(fontSize: 16)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, true);
                _showSuccessSnackBar('บันทึก "${_foodNameController.text}" เป็นเมนูประจำแล้ว!');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('บันทึก', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณากรอกข้อมูลก่อนบันทึก'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 16)),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
