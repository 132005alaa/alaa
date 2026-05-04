import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../models/daily_info.dart';

class InfoTipsPage extends StatefulWidget {
  final VoidCallback? onLeave;

  const InfoTipsPage({super.key, this.onLeave});

  @override
  State<InfoTipsPage> createState() => _InfoTipsPageState();
}

class _InfoTipsPageState extends State<InfoTipsPage> {
  bool _showIntro = true;
  bool _isLoading = true;
  String? _errorMessage;

  final ApiService _apiService = ApiService();
  List<DailyInfo> tips = [];

  @override
  void initState() {
    super.initState();
    _loadInformation();
  }

  Future<void> _loadInformation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final loadedTips = await _apiService.fetchAllInfo();
      setState(() {
        tips = loadedTips;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadInformation();
  }

  void _goBack(BuildContext context) {
    widget.onLeave?.call();
    Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Container(
                  color: const Color(0xff8FC832),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => _goBack(context),
                        child: const Icon(
                          Icons.chevron_left_outlined,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                      const Text(
                        'معلومه ع الماشي',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      GestureDetector(
                        onTap: _refreshData,
                        child: const Icon(
                          Icons.refresh,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshData,
                    child: _buildBody(),
                  ),
                ),
              ],
            ),
          ),
          if (_showIntro) _buildIntroOverlay(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xff8FC832)),
            SizedBox(height: 16),
            Text('جاري تحميل المعلومات...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadInformation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff8FC832),
              ),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (tips.isEmpty) {
      return const Center(child: Text('لا توجد معلومات لعرضها'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: tips.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) => _buildTipCard(tips[index]),
    );
  }

  Widget _buildIntroOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xffEEF7CC),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('💡', style: TextStyle(fontSize: 35)),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'معلومه ع الماشي',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'القسم ده كل يوم هيضيف معلومه مفيده؛ نصيحه خفيفه او فكره بسيطه هتفرق في يومك او يوم غيرك بمشاركتها معه',
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xff4A5A3A),
                    height: 1.8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: () => setState(() => _showIntro = false),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: const Color(0xff6BAF1A),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff6BAF1A).withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'حسناً',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTipCard(DailyInfo tip) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffE8F5C0),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(tip.Emoji, style: const TextStyle(fontSize: 38)),
                ),
              ),
              Row(
                children: [
                  Text(
                    tip.Date,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff5A6A4A),
                    ),
                  ),
                  const Text(
                    '  |  ',
                    style: TextStyle(color: Color(0xff9A9A8A), fontSize: 15),
                  ),
                  Text(
                    tip.Number,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff3A5A1A),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            tip.Text,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _actionIcon(Icons.share_outlined),
              const SizedBox(width: 10),
              _actionIcon(Icons.copy_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionIcon(IconData icon) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('سيتم إضافة هذه الميزة قريباً')),
        );
      },
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 23, color: const Color(0xff4A7C2F)),
      ),
    );
  }
}
