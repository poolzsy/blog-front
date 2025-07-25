<template>
  <div class="dashboard-container">
    <div class="dashboard-text">
      博客管理系统
    </div>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
export default {
  name: 'Dashboard',
  computed: {
    ...mapGetters([
      'name'
    ])
  }
}
</script>

<style lang="scss" scoped>
.dashboard {
  &-container {
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: calc(100vh - 60px); /* 减去顶部导航栏高度 */
    background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
    margin: 0;
    padding: 20px;
    box-sizing: border-box;
  }
  &-text {
    font-size: 72px; /* 增大字体 */
    font-weight: 700; /* 加粗 */
    line-height: 1.2;
    text-align: center;
    color: #2c3e50; /* 深蓝色文字 */
    text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.1); /* 文字阴影 */
    padding: 30px 60px;
    border-radius: 20px;
    background: white;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1); /* 添加立体阴影 */
    position: relative;
    overflow: hidden;
    
    /* 添加装饰性伪元素 */
    &::before {
      content: "";
      position: absolute;
      top: 0;
      left: 0;
      width: 5px;
      height: 100%;
      background: linear-gradient(to bottom, #3498db, #9b59b6);
    }
    
    /* 添加动画效果 */
    animation: fadeIn 1s ease-out;
  }
}

/* 文字渐入动画 */
@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* 响应式设计 */
@media (max-width: 768px) {
  .dashboard-text {
    font-size: 48px;
    padding: 20px 40px;
  }
}

@media (max-width: 480px) {
  .dashboard-text {
    font-size: 36px;
    padding: 15px 30px;
  }
}
</style>