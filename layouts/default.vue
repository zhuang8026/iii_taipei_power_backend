<template>
  <div class="wrapper">
    <el-menu class="header">
      <div class="left">
        <img src="~/assets/img/common/logo.png" width="238px" height="50px" />
      </div>
      <div v-if="!inLoginPage" class="right">
        <div v-if="!ntpc3Mode" class="home" @click.prevent="$router.push('/')">
          <img :src="require('@/assets/img/header/icon-home.svg')" alt="" />
          <p>首頁</p>
        </div>
        <div class="logout" @click.prevent="logout">
          <img :src="require('@/assets/img/header/icon-logout.svg')" alt="" />
          <p>登出</p>
        </div>
      </div>
    </el-menu>

    <main class="content">
      <el-row class="content-row">
        <!-- main content -->
        <div class="main-content">
          <nuxt />
        </div>
      </el-row>
    </main>

    <footer color="#646464" app>
      <div class="footer-text">
        版權所有 © 2018-2022 新北市政府 隱私權及資訊宣告
      </div>
    </footer>
  </div>
</template>

<script>
import { mapMutations } from 'vuex';
import backendApi from '@/assets/js/api/backendApi.js';

export default {
  computed: {
    inLoginPage() {
      return this.$route.fullPath.includes('/login') || this.$route.fullPath.includes('/reset_password');
    },
    ntpc3Mode() {
      return this.$route.fullPath.includes('ntpc3');
    },
  },
  methods: {
    ...mapMutations('user', ['CLEAR_USER_DATA']),
    async logout() {
      const vm = this;

      const res = vm.ntpc3Mode ? await backendApi.managerLogout() : await backendApi.logout();
      if (res.code === 200) {
        vm.CLEAR_USER_DATA();
        vm.$router.push(`${vm.ntpc3Mode ? '/ntpc3/login' : '/login'}`);
        vm.$message.success('登出成功');
      }
    },
  },
};
</script>

<style scoped lang="scss">
$sidebar-width: 10.5rem;

.wrapper {
  position: relative;
  display: flex;
  flex: 1 1 auto;
  flex-direction: column;
  max-width: 100%;
  min-height: 100vh;
  font-family: Noto Sans CJK TC, sans-serif;
  -webkit-backface-visibility: hidden;
  backface-visibility: hidden;

  .header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    height: 100px;
    padding: 0 120px 0 90px;
    background-color: #ffba31;

    &::before,
    &::after {
      content: none;
    }

    .home,
    .logout {
      display: flex;
      align-items: center;
      font-weight: bold;
      font-size: 1.25rem;
      cursor: pointer;
    }

    .home {
      margin-right: 15px;
    }

    .right {
      display: flex;
      align-items: center;
      color: #333;
    }
  }

  footer {
    right: 0;
    bottom: 0;
    left: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    height: 100px;
    border-color: #b2b2b2;
    background-color: #b2b2b2;

    .footer-text {
      position: relative;
      display: flex;
      justify-content: center;
      color: #fff;
      font-size: 1rem;
      letter-spacing: 1.6px;
    }
  }

  .v-application {
    font-family: 'Noto Sans TC', 'Roboto', sans-serif;
  }

  .content {
    position: relative;
    flex: 1 1 auto;
    max-width: 100%;
    min-height: 100%;

    .content-row {
      display: flex;
      flex-wrap: nowrap;
      // height: calc(100vh - 200px);
      min-height: calc(100vh - 200px);
      overflow: hidden;

      .sidebar {
        min-width: $sidebar-width;
        height: 100%;
        border-right: solid 0.0625rem #e6e6e6;
        background-color: #fff;

        a {
          color: #333;
          text-decoration: none;

          &.nuxt-link-active {
            color: $primary-color;
          }
        }
      }

      .main-content {
        // width: calc(100% - #{$sidebar-width});
        width: 100%;
        overflow: auto;
        background-color: #fff;

        div {
          &:first-child {
            height: 100%;
          }
        }
      }
    }
  }

  .footer-text {
    position: relative;
    color: #fff;

    span:nth-child(1),
    span:nth-child(4) {
      font-size: 14px;
    }

    span:nth-child(2),
    span:nth-child(5) {
      margin: 0 10px;
      font-size: 20px;
    }

    .dot {
      margin-right: 10px;
      font-size: 20px;
    }
  }
}
</style>
