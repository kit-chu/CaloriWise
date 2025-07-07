import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/text_style.dart';
import 'review_food_screen.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;

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

  // Popular food database
  final List<Map<String, dynamic>> _popularFoods = [
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

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _foodNameController.dispose();
    _caloriesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      // ใช้ resizeToAvoidBottomInset เพื่อจัดการ keyboard
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // Compact Header with Date & Meal Info
          _buildCompactHeader(),
          // Bottom Navigation Style Tabs
          _buildBottomNavTabs(),
          // Page Content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
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
    );
  }

  Widget _buildCompactHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryPurple, AppTheme.primaryPurple.withAlpha(204)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            children: [
              // Title Row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'เพิ่มอาหาร',
                      style: AppTextStyle.titleLarge(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Date Button
                  InkWell(
                    onTap: _showDatePicker,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                            '${_selectedDate.day}/${_selectedDate.month}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Meal Type Chips
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
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
          padding: const EdgeInsets.symmetric(vertical: 12),
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
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppTheme.primaryPurple : Colors.grey[600],
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Page 1: Quick Add with Search & Categories
  Widget _buildQuickAddPage() {
    return Column(
      children: [
        // Search Section
        _buildSearchSection(),
        // Categories & Results
        Expanded(
          child: _buildCategoriesAndResults(),
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
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
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  // Trigger search
                });
              },
              decoration: InputDecoration(
                hintText: 'ค้นหาอาหาร เช่น "ข้าวผัด", "ไก่ทอด"...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
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
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          // Quick Search Suggestions
          if (_searchController.text.isEmpty) ...[
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text(
                    'ค้นหาด่วน: ',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primaryPurple.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          term,
                          style: TextStyle(
                            color: AppTheme.primaryPurple,
                            fontSize: 11,
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // My Favorites
          _buildMyFavorites(),
          const SizedBox(height: 24),

          // Food Categories
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
        // Search Results Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            border: Border(
              bottom: BorderSide(color: Colors.blue[100]!),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.blue[600], size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ผลการค้นหา "${_searchController.text}" (${results.length} รายการ)',
                  style: AppTextStyle.titleSmall(context).copyWith(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Search Results List
        Expanded(
          child: results.isEmpty
              ? _buildNoSearchResults()
              : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: results.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'ไม่พบอาหารที่ค้นหา',
              style: AppTextStyle.titleMedium(context).copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ลองค้นหาด้วยคำอื่น หรือเพิ่มอาหารใหม่ในแท็บ "กรอกเอง"',
              style: AppTextStyle.bodySmall(context).copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                _pageController.animateToPage(2,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('เพิ่มอาหารใหม่'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryPurple,
                side: BorderSide(color: AppTheme.primaryPurple),
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
            // Food Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  food['icon'],
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Food Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food['name'],
                    style: AppTextStyle.bodyMedium(context).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    food['category'],
                    style: AppTextStyle.bodySmall(context).copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Calories
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${food['calories']} kcal',
                style: AppTextStyle.bodySmall(context).copyWith(
                  color: Colors.orange[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: 8),
            Icon(
              Icons.add_circle_outline,
              color: AppTheme.primaryPurple,
              size: 20,
            ),
          ],
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
            Icon(Icons.category, color: AppTheme.primaryPurple, size: 18),
            const SizedBox(width: 6),
            Text(
              'หมวดหมู่อาหาร',
              style: AppTextStyle.titleSmall(context).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Category Cards
        ...categories.map((category) => _buildCategorySection(category)),
      ],
    );
  }

  Widget _buildCategorySection(String category) {
    final categoryFoods = _popularFoods
        .where((food) => food['category'] == category)
        .toList();

    // Category icons
    final categoryIcons = {
      'อาหารไทย': '🇹🇭',
      'ฟาสต์ฟู้ด': '🍔',
      'เพื่อสุขภาพ': '🥗',
      'ผลไม้': '🍎',
      'เครื่องดื่ม': '🥤',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          // Category Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                Text(
                  categoryIcons[category] ?? '🍽️',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    category,
                    style: AppTextStyle.titleSmall(context).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${categoryFoods.length}',
                    style: TextStyle(
                      color: AppTheme.primaryPurple,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Category Foods
          Padding(
            padding: const EdgeInsets.all(8),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.8,
                crossAxisSpacing: 8,
                mainAxisSpacing: 6,
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
            Icon(Icons.bookmark, color: AppTheme.primaryPurple, size: 18),
            const SizedBox(width: 6),
            Text(
              'เมนูประจำ',
              style: AppTextStyle.titleSmall(context).copyWith(
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
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: myFavorites.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
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
        width: 100,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryPurple.withOpacity(0.1),
              AppTheme.primaryPurple.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(food['icon'], style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              food['name'],
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${food['calories']} kcal',
              style: TextStyle(
                fontSize: 9,
                color: AppTheme.primaryPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularFoodsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'อาหารยอดนิยม',
          style: AppTextStyle.titleSmall(context).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 8,
          ),
          itemCount: _popularFoods.take(6).length, // Show only top 6
          itemBuilder: (context, index) {
            final food = _popularFoods[index];
            return _buildFoodCard(food);
          },
        ),
      ],
    );
  }

  Widget _buildFoodCard(Map<String, dynamic> food) {
    return GestureDetector(
      onTap: () => _showQuickAddConfirmation(food),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Text(food['icon'], style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    food['name'],
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${food['calories']} kcal',
                    style: TextStyle(
                      fontSize: 9,
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
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!_isAnalyzing && !_analysisComplete) ...[
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primaryPurple, width: 3),
                color: AppTheme.primaryPurple.withOpacity(0.1),
              ),
              child: InkWell(
                onTap: _startAIAnalysis,
                borderRadius: BorderRadius.circular(80),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt,
                      size: 50,
                      color: AppTheme.primaryPurple,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ถ่ายรูป',
                      style: TextStyle(
                        color: AppTheme.primaryPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'AI จะวิเคราะห์และคำนวณแคลอรี่ให้อัตโนมัติ',
              style: AppTextStyle.bodyMedium(context).copyWith(
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
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            strokeWidth: 4,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryPurple),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'กำลังวิเคราะห์...',
          style: AppTextStyle.titleMedium(context).copyWith(
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
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: const DecorationImage(
              image: NetworkImage('https://picsum.photos/400/300'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
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
                style: AppTextStyle.titleMedium(context).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '350 แคลอรี่',
                style: AppTextStyle.titleLarge(context).copyWith(
                  color: AppTheme.primaryPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _confirmAIResult,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'เพิ่มอาหารนี้',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Photo Section
          _buildPhotoSection(),
          const SizedBox(height: 16),

          // Food Name Input
          TextField(
            controller: _foodNameController,
            decoration: InputDecoration(
              labelText: 'ชื่ออาหาร',
              hintText: 'เช่น ข้าวผัดแม่ทำ',
              prefixIcon: Icon(Icons.restaurant, color: AppTheme.primaryPurple),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          const SizedBox(height: 16),

          // Calories Input
          TextField(
            controller: _caloriesController,
            decoration: InputDecoration(
              labelText: 'แคลอรี่ (kcal)',
              prefixIcon: Icon(Icons.local_fire_department, color: Colors.orange),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.orange.withOpacity(0.05),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),

          // Quick Calorie Buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['100', '200', '300', '400', '500'].map((cal) =>
                _buildQuickCalorieChip('$cal kcal')
            ).toList(),
          ),
          const SizedBox(height: 24),

          // Submit Buttons
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitManualFood,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'เพิ่มอาหาร',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _saveToFavorites,
                  icon: const Icon(Icons.bookmark_add, size: 18),
                  label: const Text('บันทึกเป็นเมนูประจำ'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryPurple,
                    side: BorderSide(color: AppTheme.primaryPurple),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[50],
      ),
      child: InkWell(
        onTap: _takePhoto,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo, size: 30, color: Colors.grey[600]),
            const SizedBox(height: 4),
            Text(
              'ถ่ายรูปอาหาร (ไม่บังคับ)',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickCalorieChip(String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () {
        final calories = text.replaceAll(' kcal', '');
        _caloriesController.text = calories;
      },
      backgroundColor: AppTheme.primaryPurple.withOpacity(0.1),
      labelStyle: TextStyle(
        color: AppTheme.primaryPurple,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );
  }

  // Helper Methods
  void _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _showQuickAddConfirmation(Map<String, dynamic> food) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Food Icon (Large)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  food['icon'],
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Food Name (Prominent)
            Text(
              food['name'],
              style: AppTextStyle.titleLarge(context).copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Calories (Very Prominent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    '${food['calories']} แคลอรี่',
                    style: AppTextStyle.titleMedium(context).copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Meal Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        _selectedMealType,
                        style: AppTextStyle.bodyMedium(context).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: AppTextStyle.bodySmall(context).copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(color: Colors.grey[400]!),
                    ),
                    child: Text(
                      'ยกเลิก',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context, true);
                      _showSuccessSnackBar('เพิ่ม ${food['name']} สำเร็จ!');
                    },
                    icon: const Icon(Icons.add_circle, color: Colors.white, size: 20),
                    label: const Text(
                      'เพิ่มอาหารนี้',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPurple,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
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
    // Simplified management - go to manual tab
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
          title: Row(
            children: [
              Icon(Icons.bookmark_add, color: AppTheme.primaryPurple),
              const SizedBox(width: 8),
              const Text('บันทึกเมนูประจำ'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('เมนู: ${_foodNameController.text}'),
              Text('แคลอรี่: ${_caloriesController.text} kcal'),
              const SizedBox(height: 12),
              Text(
                'บันทึกเป็นเมนูประจำเพื่อเลือกใช้งานได้ง่ายในครั้งถัดไป',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, true);
                _showSuccessSnackBar('บันทึก "${_foodNameController.text}" เป็นเมนูประจำแล้ว!');
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryPurple),
              child: const Text('บันทึก', style: TextStyle(color: Colors.white)),
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
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}