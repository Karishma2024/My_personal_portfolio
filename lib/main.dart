// lib/main.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const KarishmaPortfolioApp());

class KarishmaPortfolioApp extends StatelessWidget {
  const KarishmaPortfolioApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shaik Karishma — Portfolio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const PortfolioPage(),
    );
  }
}

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});
  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  final Map<String, GlobalKey> _keys = {
    'About': GlobalKey(),
    'Education': GlobalKey(),
    'Experience': GlobalKey(),
    'Projects': GlobalKey(),
    'Skills': GlobalKey(),
    'Contact': GlobalKey(),
  };

  final Map<String, bool> _revealed = {};
  bool _showBackToTop = false;

  final List<_NavInfo> _navItems = [
    _NavInfo('About', Icons.person),
    _NavInfo('Education', Icons.school),
    _NavInfo('Experience', Icons.work),
    _NavInfo('Projects', Icons.code),
    _NavInfo('Skills', Icons.handyman),
    _NavInfo('Contact', Icons.mail),
  ];

  @override
  void initState() {
    super.initState();
    for (var k in _keys.keys) _revealed[k] = false;

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _revealVisibleSections(),
    );

    _scrollController.addListener(() {
      _revealVisibleSections();
      final show = _scrollController.offset > 420;
      if (show != _showBackToTop) setState(() => _showBackToTop = show);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _revealVisibleSections() {
    final vp = MediaQuery.of(context).size.height;
    bool changed = false;
    _keys.forEach((name, key) {
      final ctx = key.currentContext;
      if (ctx == null) return;
      final box = ctx.findRenderObject() as RenderBox;
      final pos = box.localToGlobal(Offset.zero);
      final trigger = pos.dy < vp * 0.82;
      if (trigger && (_revealed[name] == false)) {
        _revealed[name] = true;
        changed = true;
      }
    });
    if (changed) setState(() {});
  }

  Future<void> _scrollTo(String name) async {
    final ctx = _keys[name]!.currentContext;
    if (ctx == null) return;
    await Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOutCubic,
      alignment: 0.0,
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;
    final sectionPadding = EdgeInsets.symmetric(
      horizontal: isDesktop ? 56 : 20,
      vertical: isDesktop ? 28 : 18,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF051428), Color(0xFF0F2B63)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // Fixed full-width transparent navbar (floating appearance)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                border: Border(bottom: BorderSide(color: Colors.white10)),
              ),
              child: Row(
                children: [
                  const Text(
                    'Shaik Karishma',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: _navItems.map((n) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: _NavText(
                          label: n.label,
                          onTap: () => _scrollTo(n.label),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // Content (single page scrolling)
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // HERO - About split (photo left, about right) with slight offset effect
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final vpHeight =
                            MediaQuery.of(context).size.height -
                            96; // full viewport minus nav
                        final baseCardHeight = isDesktop
                            ? vpHeight * 0.62
                            : null; // for desktop we set a target
                        final aboutHeight =
                            baseCardHeight ?? null as double? ?? null;
                        // On desktop we'll calculate heights to create slight offset: image taller than about card
                        return Container(
                          key: _keys['About'],
                          height: isDesktop ? vpHeight : null,
                          padding: sectionPadding,
                          child: isDesktop
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // left: photo (slightly taller than about card)
                                    Expanded(
                                      flex: 4,
                                      child: Center(
                                        child: _AnimatedReveal(
                                          visible: true,
                                          delay: 80,
                                          child: Builder(
                                            builder: (ctx) {
                                              // compute aboutCardHeight from parent width to determine image height -> slight offset
                                              final containerWidth =
                                                  constraints.maxWidth;
                                              final aboutCardWidth =
                                                  containerWidth *
                                                  0.54; // approx
                                              final aboutCardHeight =
                                                  aboutCardWidth *
                                                  0.42; // ratio tuned for balance
                                              final imageHeight =
                                                  aboutCardHeight *
                                                  1.12; // 12% taller (offset effect)
                                              return SizedBox(
                                                height: imageHeight,
                                                child: _ImageCard(
                                                  imagePath:
                                                      'assets/images/avatar.jpg',
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 36),
                                    // right: about card (slightly shorter)
                                    Expanded(
                                      flex: 7,
                                      child: Center(
                                        child: _AnimatedReveal(
                                          visible: true,
                                          delay: 220,
                                          child: SizedBox(
                                            // keep about card a bit shorter than image (complement the offset)
                                            height:
                                                MediaQuery.of(
                                                  context,
                                                ).size.height *
                                                0.52,
                                            child: _GlassCard(
                                              title: Row(
                                                children: const [
                                                  Icon(
                                                    Icons.person,
                                                    color: Colors.white70,
                                                  ),
                                                  SizedBox(width: 10),
                                                  Text('About Me'),
                                                ],
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Text(
                                                    'Shaik Karishma',
                                                    style: TextStyle(
                                                      fontSize: 28,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  const Text(
                                                    'IT Graduate | Aspiring Software Engineer',
                                                    style: TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 14),
                                                  const Text(
                                                    "As an IT graduate, I enjoy solving problems through technology and creativity. I’m passionate about learning new tools, building projects, and growing with every experience.",
                                                    style: TextStyle(
                                                      color: Colors.white70,
                                                      height: 1.45,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 18),
                                                  Row(
                                                    children: [
                                                      ElevatedButton.icon(
                                                        onPressed: () => _openUrl(
                                                          'mailto:karishmashaik055@gmail.com',
                                                        ),
                                                        icon: const Icon(
                                                          Icons.email,
                                                        ),
                                                        label: const Text(
                                                          'Email',
                                                        ),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.blueAccent,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      OutlinedButton.icon(
                                                        onPressed: () => _openUrl(
                                                          'https://linkedin.com/in/shaik-karishma-476006251',
                                                        ),
                                                        icon: const Icon(
                                                          Icons.link,
                                                        ),
                                                        label: const Text(
                                                          'LinkedIn',
                                                        ),
                                                        style: OutlinedButton.styleFrom(
                                                          foregroundColor:
                                                              Colors.white70,
                                                          side:
                                                              const BorderSide(
                                                                color: Colors
                                                                    .white24,
                                                              ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    _AnimatedReveal(
                                      visible: true,
                                      delay: 80,
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: _ImageCard(
                                          imagePath: 'assets/images/avatar.jpg',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    _AnimatedReveal(
                                      visible: true,
                                      delay: 220,
                                      child: _GlassCard(
                                        title: Row(
                                          children: const [
                                            Icon(
                                              Icons.person,
                                              color: Colors.white70,
                                            ),
                                            SizedBox(width: 10),
                                            Text('About Me'),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: const [
                                            Text(
                                              'Shaik Karishma',
                                              style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'IT Graduate | Aspiring Software Engineer',
                                              style: TextStyle(
                                                color: Colors.white70,
                                              ),
                                            ),
                                            SizedBox(height: 12),
                                            Text(
                                              "As an IT graduate, I enjoy solving problems through technology and creativity. I’m passionate about learning new tools, building projects, and growing with every experience.",
                                              style: TextStyle(
                                                color: Colors.white70,
                                                height: 1.45,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        );
                      },
                    ),
                    const SizedBox(height: 36),

                    // EDUCATION
                    _SectionWithReveal(
                      keyObj: _keys['Education']!,
                      visible: _revealed['Education'] ?? false,
                      delay: 60,
                      child: Padding(
                        padding: sectionPadding,
                        child: _GlassCard(
                          title: Row(
                            children: const [
                              Icon(Icons.school, color: Colors.white70),
                              SizedBox(width: 10),
                              Text('Education'),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              _EduItem(
                                title:
                                    'B. Tech – JNTUH University College of Engineering, Jagtial',
                                subtitle: 'Year of Passing: 2024 | CGPA: 8.2',
                              ),
                              SizedBox(height: 12),
                              _EduItem(
                                title:
                                    'Intermediate – Narayana Junior College, Hyderabad',
                                subtitle:
                                    'Year of Passing: 2020 | Percentage: 96%',
                              ),
                              SizedBox(height: 12),
                              _EduItem(
                                title:
                                    'SSC – Little Flower High School, Miryalaguda',
                                subtitle: 'Year of Passing: 2018 | CGPA: 9.8',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // EXPERIENCE
                    _SectionWithReveal(
                      keyObj: _keys['Experience']!,
                      visible: _revealed['Experience'] ?? false,
                      delay: 90,
                      child: Padding(
                        padding: sectionPadding,
                        child: _GlassCard(
                          title: Row(
                            children: const [
                              Icon(Icons.work, color: Colors.white70),
                              SizedBox(width: 10),
                              Text('Work Experience'),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              _ExpItem(
                                title:
                                    'Customer Support Associate | Tech Mahindra, Hyd.',
                                period: 'November 2024 - May 2025',
                                bullets: [
                                  'Delivered chat-based support for UK customers, resolving billing and service issues.',
                                  'Used SAP C4C to manage customer data and service requests.',
                                  'Maintained a 95% CSAT score and consistently met performance targets.',
                                ],
                              ),
                              SizedBox(height: 18),
                              _ExpItem(
                                title:
                                    'Software Associate Engineer (Trainee) | Nexnora Technologies Pvt. Ltd., Hyd.',
                                period: 'June 2025 – Present',
                                bullets: [
                                  'Undergoing hands-on training focused on core Python programming and software development fundamentals.',
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // PROJECTS
                    _SectionWithReveal(
                      keyObj: _keys['Projects']!,
                      visible: _revealed['Projects'] ?? false,
                      delay: 120,
                      child: Padding(
                        padding: sectionPadding,
                        child: _GlassCard(
                          title: Row(
                            children: const [
                              Icon(Icons.code, color: Colors.white70),
                              SizedBox(width: 10),
                              Text('Academic Project'),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Traffic Sign Recognition Using Convolutional Neural Networks',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 10),
                              _Bullet(
                                text:
                                    'Led a team of 4 members to design and implement the traffic sign recognition system.',
                              ),
                              _Bullet(
                                text:
                                    'Coordinated tasks, managed schedules, and ensured timely completion of project milestones.',
                              ),
                              _Bullet(
                                text:
                                    'Successfully developed a CNN-based traffic sign recognition system achieving 95% accuracy to improve reliability of autonomous driving systems.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // SKILLS
                    _SectionWithReveal(
                      keyObj: _keys['Skills']!,
                      visible: _revealed['Skills'] ?? false,
                      delay: 150,
                      child: Padding(
                        padding: sectionPadding,
                        child: _GlassCard(
                          title: Row(
                            children: const [
                              Icon(Icons.handyman, color: Colors.white70),
                              SizedBox(width: 10),
                              Text('Skills'),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              const Text(
                                'Programming Languages:',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                children: const [
                                  _SkillChipLabel('Python'),
                                  _SkillChipLabel('Dart'),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Libraries & Frameworks:',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                children: const [
                                  _SkillChipLabel('NumPy'),
                                  _SkillChipLabel('Pandas'),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Tools & Version Control:',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Git (Basic version control operations - clone, commit, push, pull)',
                                style: TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Personal Skills:',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                children: const [
                                  _SkillChipLabel('Problem Solving'),
                                  _SkillChipLabel('Good Communication'),
                                  _SkillChipLabel('Keen to Learn'),
                                  _SkillChipLabel('Team Collaboration'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // CONTACT
                    _SectionWithReveal(
                      keyObj: _keys['Contact']!,
                      visible: _revealed['Contact'] ?? false,
                      delay: 180,
                      child: Padding(
                        padding: sectionPadding,
                        child: _GlassCard(
                          title: Row(
                            children: const [
                              Icon(Icons.mail, color: Colors.white70),
                              SizedBox(width: 10),
                              Text('Contact'),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () => _openUrl(
                                  'mailto:karishmashaik055@gmail.com',
                                ),
                                child: const Text(
                                  'Email: karishmashaik055@gmail.com',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Phone: +91 8179073132',
                                style: TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => _openUrl(
                                  'https://linkedin.com/in/shaik-karishma-476006251',
                                ),
                                child: const Text(
                                  'LinkedIn: linkedin.com/in/shaik-karishma-476006251',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _showBackToTop
          ? FloatingActionButton(
              backgroundColor: Colors.blueAccent,
              onPressed: () => _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeInOut,
              ),
              child: const Icon(Icons.arrow_upward),
            )
          : null,
    );
  }
}

// ------------------ Helper Widgets ------------------

class _NavInfo {
  final String label;
  final IconData icon;
  _NavInfo(this.label, this.icon);
}

/// nav text with gradient shimmer on hover
class _NavText extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _NavText({required this.label, required this.onTap, super.key});

  @override
  State<_NavText> createState() => _NavTextState();
}

class _NavTextState extends State<_NavText>
    with SingleTickerProviderStateMixin {
  bool _hover = false;
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hover) {
      if (!_anim.isAnimating) _anim.repeat(reverse: true);
    } else {
      if (_anim.isAnimating) _anim.stop();
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: _hover
              ? AnimatedBuilder(
                  animation: _anim,
                  builder: (context, child) {
                    final t = (_anim.value * 2) - 1; // -1..1
                    final dx = 0.6 * t;
                    final gradient = LinearGradient(
                      begin: Alignment(-1 + dx, 0),
                      end: Alignment(1 + dx, 0),
                      colors: const [
                        Colors.white70,
                        Colors.white,
                        Colors.white70,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    );
                    return ShaderMask(
                      shaderCallback: (rect) => gradient.createShader(rect),
                      blendMode: BlendMode.srcIn,
                      child: Text(
                        widget.label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                )
              : Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}

/// glass card with hover elevation (same transparency across all)
class _GlassCard extends StatefulWidget {
  final Widget title;
  final Widget child;
  const _GlassCard({required this.title, required this.child, super.key});

  @override
  State<_GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<_GlassCard> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(_hover ? 0.11 : 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_hover ? 0.28 : 0.18),
              blurRadius: _hover ? 16 : 10,
              offset: Offset(0, _hover ? 12 : 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [widget.title, const SizedBox(height: 12), widget.child],
        ),
      ),
    );
  }
}

/// Image card (rounded rectangle)
class _ImageCard extends StatefulWidget {
  final String imagePath;
  const _ImageCard({required this.imagePath, super.key});
  @override
  State<_ImageCard> createState() => _ImageCardState();
}

class _ImageCardState extends State<_ImageCard> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_hover ? 0.28 : 0.16),
              blurRadius: _hover ? 18 : 10,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: Colors.white10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 4 / 5,
            child: Image.asset(
              widget.imagePath,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) {
                return Container(
                  color: Colors.white12,
                  child: const Center(
                    child: Icon(Icons.person, size: 64, color: Colors.white24),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated reveal used across the page
class _AnimatedReveal extends StatelessWidget {
  final Widget child;
  final bool visible;
  final int delay;
  const _AnimatedReveal({
    required this.child,
    required this.visible,
    this.delay = 0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final beginOffset = const Offset(0, 18);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: visible ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, v, ch) {
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, beginOffset.dy * (1 - v)),
            child: ch,
          ),
        );
      },
      child: child,
    );
  }
}

/// Section wrapper with padding
class _SectionWithReveal extends StatelessWidget {
  final GlobalKey keyObj;
  final Widget child;
  final bool visible;
  final int delay;
  const _SectionWithReveal({
    required this.keyObj,
    required this.child,
    required this.visible,
    this.delay = 0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: keyObj,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: _AnimatedReveal(visible: visible, delay: delay, child: child),
    );
  }
}

// Education item (two-line style)
class _EduItem extends StatelessWidget {
  final String title;
  final String subtitle;
  const _EduItem({required this.title, required this.subtitle, super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }
}

// Experience item (title, date, bullets)
class _ExpItem extends StatelessWidget {
  final String title;
  final String period;
  final List<String> bullets;
  const _ExpItem({
    required this.title,
    required this.period,
    required this.bullets,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          period,
          style: const TextStyle(color: Colors.white60, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Column(
          children: bullets
              .map(
                (b) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    Expanded(
                      child: Text(
                        b,
                        style: const TextStyle(
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

// Bullet row for projects
class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet({required this.text, super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

// Skill chip small label
class _SkillChipLabel extends StatefulWidget {
  final String label;
  const _SkillChipLabel(this.label, {super.key});
  @override
  State<_SkillChipLabel> createState() => _SkillChipLabelState();
}

class _SkillChipLabelState extends State<_SkillChipLabel> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(_hover ? 0.16 : 0.10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white12),
          boxShadow: _hover
              ? [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.14),
                    blurRadius: 12,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Text(
          widget.label,
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
