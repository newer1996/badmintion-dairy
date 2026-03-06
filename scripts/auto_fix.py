#!/usr/bin/env python3
"""
自动修复 GitHub Actions 构建失败的脚本
分析构建日志，识别常见问题并自动修复
"""

import os
import re
import subprocess
import sys
from pathlib import Path

class BuildAutoFixer:
    def __init__(self):
        self.project_root = Path(__file__).parent.parent
        self.fixes_applied = []
        self.errors_found = []
    
    def analyze_and_fix(self):
        """分析并修复常见问题"""
        print("🔍 分析构建问题...")
        
        # 检查 1: Flutter analyze 错误
        self.fix_flutter_analyze_errors()
        
        # 检查 2: Android 配置问题
        self.fix_android_config()
        
        # 检查 3: 缺少资源文件
        self.fix_missing_resources()
        
        # 检查 4: 依赖问题
        self.fix_dependency_issues()
        
        # 报告结果
        self.report_results()
    
    def fix_flutter_analyze_errors(self):
        """修复 Flutter analyze 错误"""
        print("\n📋 检查 Flutter 代码问题...")
        
        # 检查未使用的导入
        lib_dir = self.project_root / "lib"
        for dart_file in lib_dir.rglob("*.dart"):
            content = dart_file.read_text()
            
            # 修复: 添加缺少的导入
            if "Color" in content and "import 'package:flutter/material.dart'" not in content:
                if "class Activity" in content or "get statusColor" in content:
                    print(f"  🔧 修复: {dart_file} 缺少 Color 导入")
                    content = "import 'package:flutter/material.dart';\n" + content
                    dart_file.write_text(content)
                    self.fixes_applied.append(f"Added Flutter import to {dart_file.name}")
    
    def fix_android_config(self):
        """修复 Android 配置问题"""
        print("\n🤖 检查 Android 配置...")
        
        android_dir = self.project_root / "android"
        
        # 检查 gradle.properties
        gradle_props = android_dir / "gradle.properties"
        if not gradle_props.exists():
            print("  🔧 修复: 创建 gradle.properties")
            gradle_props.write_text("""org.gradle.jvmargs=-Xmx4G -XX:MaxMetaspaceSize=2G -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8
android.useAndroidX=true
android.enableJetifier=true
""")
            self.fixes_applied.append("Created gradle.properties with AndroidX enabled")
        
        # 检查 local.properties
        local_props = android_dir / "local.properties"
        if not local_props.exists():
            print("  🔧 修复: 创建 local.properties")
            flutter_sdk = os.environ.get("FLUTTER_ROOT", "/opt/flutter")
            local_props.write_text(f"flutter.sdk={flutter_sdk}\n")
            self.fixes_applied.append("Created local.properties")
    
    def fix_missing_resources(self):
        """修复缺少的资源文件"""
        print("\n🎨 检查资源文件...")
        
        res_dir = self.project_root / "android" / "app" / "src" / "main" / "res"
        
        # 检查图标
        mipmap_dirs = ["mipmap-mdpi", "mipmap-hdpi", "mipmap-xhdpi", "mipmap-xxhdpi", "mipmap-xxxhdpi"]
        sizes = {"mipmap-mdpi": 48, "mipmap-hdpi": 72, "mipmap-xhdpi": 96, "mipmap-xxhdpi": 144, "mipmap-xxxhdpi": 192}
        
        for mipmap in mipmap_dirs:
            mipmap_dir = res_dir / mipmap
            mipmap_dir.mkdir(parents=True, exist_ok=True)
            
            icon_file = mipmap_dir / "ic_launcher.png"
            if not icon_file.exists() or icon_file.stat().st_size == 0:
                print(f"  🔧 修复: 创建 {mipmap}/ic_launcher.png")
                # 创建简单的绿色 PNG
                self.create_simple_png(icon_file, sizes[mipmap])
                self.fixes_applied.append(f"Created {mipmap}/ic_launcher.png")
    
    def create_simple_png(self, filepath, size):
        """创建简单的 PNG 图标"""
        try:
            from PIL import Image, ImageDraw
            img = Image.new('RGBA', (size, size), (7, 193, 96, 255))
            draw = ImageDraw.Draw(img)
            padding = size // 4
            draw.ellipse([padding, padding, size-padding, size-padding], fill=(255, 255, 255, 255))
            img.save(filepath)
        except ImportError:
            # 如果没有 PIL，创建空文件（会被检测到）
            filepath.touch()
    
    def fix_dependency_issues(self):
        """修复依赖问题"""
        print("\n📦 检查依赖问题...")
        
        pubspec = self.project_root / "pubspec.yaml"
        if pubspec.exists():
            content = pubspec.read_text()
            
            # 检查是否引用了不存在的字体
            if "fonts:" in content and "NotoSansSC" in content:
                fonts_dir = self.project_root / "assets" / "fonts"
                if not fonts_dir.exists() or not list(fonts_dir.glob("*.otf")):
                    print("  🔧 修复: 移除未包含的字体配置")
                    # 移除字体配置
                    lines = content.split('\n')
                    new_lines = []
                    in_fonts = False
                    for line in lines:
                        if line.strip().startswith("fonts:"):
                            in_fonts = True
                            continue
                        if in_fonts:
                            if line.strip() and not line.startswith(' ') and not line.startswith('#'):
                                in_fonts = False
                                new_lines.append(line)
                        else:
                            new_lines.append(line)
                    
                    pubspec.write_text('\n'.join(new_lines))
                    self.fixes_applied.append("Removed font configuration for missing fonts")
    
    def report_results(self):
        """报告修复结果"""
        print("\n" + "="*50)
        print("📊 自动修复报告")
        print("="*50)
        
        if self.fixes_applied:
            print(f"\n✅ 已应用 {len(self.fixes_applied)} 个修复:")
            for fix in self.fixes_applied:
                print(f"   • {fix}")
        else:
            print("\nℹ️ 未发现需要修复的问题")
        
        if self.errors_found:
            print(f"\n⚠️ 发现 {len(self.errors_found)} 个错误:")
            for error in self.errors_found:
                print(f"   • {error}")
        
        print("\n" + "="*50)
        
        # 如果有修复，建议提交
        if self.fixes_applied:
            print("\n📝 建议执行:")
            print("   git add -A")
            print("   git commit -m 'Auto-fix: 修复构建问题'")
            print("   git push origin master")

if __name__ == "__main__":
    fixer = BuildAutoFixer()
    fixer.analyze_and_fix()
