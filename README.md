---
# 工程计算与系统仿真实验集
# Engineering Computing & System Simulation Suite
## 📖 项目简介 | Introduction
本项目包含一系列基于 MATLAB 开发的工程计算与系统仿真任务。项目涵盖了数值分析、信号处理模型以及动态系统仿真，展示了从数学建模到算法实现的完整工程逻辑。
This repository contains a comprehensive collection of engineering computing and system simulation tasks developed in MATLAB. The project covers numerical analysis, signal processing models, and dynamic system simulations, demonstrating the full engineering pipeline from mathematical modeling to algorithmic implementation.
---
## 📂 任务概览 | Tasks Overview
本项目由 6 个核心任务组成，每个任务侧重于不同的工程计算领域：
The project consists of six core tasks, each focusing on a different domain of engineering computation:
| 任务编号 | 文件类型 | 核心内容描述 (Description) |
| --- | --- | --- |
| **Task 1 & 2** | `.m` Scripts | **基础数值算法实现**：侧重于高效算法的底层逻辑与代码实现。 |
| **Task 3 - 5** | `.mlx` Live Scripts | **交互式系统建模**：利用 MATLAB 实时脚本实现数学推导、可视化绘图与结果分析的深度集成。 |
| **Task 6** | `.m` Script | **综合系统集成**：针对复杂工程问题的模块化封装与最终方案实现。 |
| **Test Module** | `test.m` | **单元测试与验证**：确保各任务算法的鲁棒性与计算精度。 |
---
## ✨ 技术亮点 | Technical Highlights
* **交互式文档化 (Interactive Documentation)**: `Task 3-5` 采用 MATLAB Live Script 格式，将公式推导、仿真代码与运行结果完美融合，极大提升了学术交流的可读性。
* **数值稳定性 (Numerical Stability)**: 算法实现过程中充分考虑了计算精度与收敛性，通过 `test.m` 进行严格的参数验证。
* **模块化设计 (Modular Design)**: 代码结构遵循高内聚低耦合原则，方便在通信系统仿真中进行二次开发与调用。
---
## 🚀 使用指南 | Quick Start
1. **克隆仓库 (Clone the repo)**:
```bash
git clone https://github.com/YourUsername/Engineering-Simulation-Suite.git
```
2. **环境要求 (Environment)**: 建议使用 **MATLAB R2023b** 或更高版本以获得最佳的 `.mlx` 阅读体验。
3. **运行任务 (Run Tasks)**:
* 直接在 MATLAB 中打开 `Tasks/` 下的对应文件即可。
* 运行 `test.m` 可以一次性验证所有核心模块的有效性。
