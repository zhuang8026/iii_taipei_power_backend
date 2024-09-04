<template>
  <div class="login" v-loading.fullscreen.lock="loading">
    <div class="login-bg">
      <div class="login-form">
        <h2 class="title">
          用戶登入
        </h2>
        <el-form
          ref="loginForm"
          :model="loginForm"
          :rules="rules"
          label-width="100px"
          class="demo-ruleForm"
          :before-close="closeEdit"
        >
          <el-form-item label="帳號" prop="account" margin-left="0">
            <el-input v-model="loginForm.account" placeholder="請輸入帳號" />
          </el-form-item>
          <el-form-item class="mark">
            <span>*請注意帳號有區分大小寫</span>
          </el-form-item>
          <el-form-item label="密碼" prop="password">
            <el-input
              v-model="loginForm.password"
              placeholder="請輸入密碼"
              show-password
            />
          </el-form-item>
          <el-form-item class="forget-password">
            <a @click="showDialog = true">忘記密碼？</a>
          </el-form-item>
          <el-form-item>
            <el-button class="btn" @click="validateForm('loginForm')">
              登&ensp;入
            </el-button>
          </el-form-item>
        </el-form>
      </div>
    </div>
    <!--忘記密碼彈窗-->
    <div class="forget-password-box">
      <el-dialog
        title="忘記密碼"
        :visible.sync="showDialog"
        :modal-append-to-body="false"
        :before-close="closeResetPassword"
      >
        <div class="text-box">
          <span class="text"
            >請輸入註冊時使用的電子信箱，稍後您將會收到密碼重設信件</span
          >
        </div>

        <div class="dialog-body">
          <label>帳號</label>
          <el-input
            v-model="email"
            placeholder="請輸入電子信箱"
            @blur="validateEmail()"
          />
        </div>
        <p v-if="forgetPasswordError" class="forget-password-error">
          請輸入電子信箱
        </p>

        <div slot="footer" class="dialog-footer">
          <el-button @click="closeResetPassword()">
            取消
          </el-button>
          <el-button @click="resetPassword()">
            重設密碼
          </el-button>
        </div>
      </el-dialog>
    </div>
  </div>
</template>

<script>
import backendApi from '@/assets/js/api/backendApi.js';
import { mapMutations } from 'vuex';

export default {
  data: () => ({
    loading: false,
    loginForm: {
      account: '',
      passsword: '',
    },
    rules: {
      account: [
        {
          required: true,
          message: '請輸入帳號',
          trigger: 'blur',
        },
      ],
      password: [
        {
          required: true,
          message: '請輸入密碼',
          trigger: 'blur',
        },
      ],
    },
    email: '',
    showDialog: false, // 忘記密碼彈窗
    forgetPasswordError: false,
  }),
  computed: {},
  methods: {
    ...mapMutations('user', ['SET_USER_DATA']),
    validateForm(formName) {
      const vm = this;
      vm.$refs[formName].validate((valid) => {
        if (valid) {
          vm.login();
        }
      });
    },
    async login() {
      const vm = this;
      const data = {
        userId: vm.loginForm.account,
        userPwd: vm.loginForm.password,
      };
      vm.loading = true;
      const res = await backendApi.login(data);
      if (res.code === 200) {
        vm.SET_USER_DATA(res.data);
        vm.$router.push('/');
        vm.$message.success('登入成功');
      }
      vm.loading = false;
    },
    // 關問卷之前資料重置
    closeEdit(done) {
      const vm = this;
      vm.$refs.loginFormForm.resetFields();
      done();
    },
    validateEmail() {
      const vm = this;
      if (!vm.email) {
        vm.forgetPasswordError = true;
        return false;
      }
      vm.forgetPasswordError = false;

      return true;
    },
    closeResetPassword() {
      const vm = this;
      vm.email = '';
      vm.showDialog = false;
    },
    async resetPassword() {
      const vm = this;
      if (vm.validateEmail()) {
        vm.loading = true;
        const res = await backendApi.passwordForget(vm.email);
        if (res.code === 200) {
          vm.loading = false;
          vm.$message({
            message: '已發送信件，請於48小時內查看',
            type: 'success',
          });

          vm.showDialog = false;
        } else {
          vm.loading = false;
        }
      }
    },
  },
};
</script>
<style scoped lang="scss">
.login {
  padding: 10.5rem 0;
  font-family: Noto Sans CJK TC, sans-serif;

  .login-bg {
    position: relative;
    width: 56.5rem;
    margin: 0 auto;
    border-radius: 10px;
    background-color: #fff;
    box-shadow: 7px 7px 7px #00000029;
  }

  .login-form {
    width: 30rem;
    margin: 0 auto;
    padding: 4.6rem 0;
  }

  .title {
    margin-bottom: 3rem;
    color: #333;
    font-size: 1.625rem;
    //font-family: Noto Sans CJK TC, sans-serif;
    text-align: center;
  }

  /* 表單 */
  /deep/ .el-form-item {
    display: flex;
    align-items: center;
    margin-bottom: 0;
  }

  /deep/ .el-form-item__label {
    flex-basis: 15%;
    padding: 0;
    color: #333;
    font-weight: bolder;
    font-size: 1.25rem;
    //font-family: Noto Sans CJK TC, sans-serif;
    text-align: left;
  }

  /deep/ .el-form-item__label::before {
    display: none;
  }

  /deep/ .el-input {
    position: relative;
    width: 100%;
  }

  /deep/ .el-input__inner {
    height: 3.125rem;
    padding: 0 1.5rem;
    border: 1px solid #b5b5b5;
    font-size: 1rem;
    line-height: 3.125rem;
    letter-spacing: 0.1rem;
  }

  /deep/ .el-form-item__content {
    flex-basis: 100%;
    margin-left: 0 !important;
  }

  .mark {
    margin: 0.4rem 0 0.7rem 4.3rem;

    span {
      color: #333;
      font-size: 0.875rem;
      letter-spacing: 0.1rem;
      //font-family: Noto Sans CJK TC, sans-serif;
    }
  }

  .forget-password-error {
    position: relative;
    top: 0.1rem;
    width: fit-content;
    margin-left: 12%;
    color: #f56c6c;
  }

  .forget-password {
    margin: 0.8rem 0;
    text-align: right;

    a {
      color: #333;
      font-weight: bolder;
      font-size: 1.125rem;
      text-decoration: underline;
      cursor: pointer;
    }
  }

  .btn {
    width: 100%;
    //padding: 1rem 0.75rem;
    border-color: #ffd081;
    color: #fff;
    font-size: 1.125rem;
    background-color: #ffd081;
    transition: 0.3s;

    &:hover {
      border-color: #ffa103;
      background-color: #ffa103;
    }
  }

  /* 忘記密碼框 */
  /deep/ .el-dialog {
    // width: 50rem;
    padding: 0 6rem;
    // font-family: Noto Sans CJK TC, sans-serif;

    .el-button {
      width: 9.5rem;
      padding: 0;
    }

    .text {
      color: #333;
      font-weight: bolder;
      font-size: 1rem;
      letter-spacing: 0.08rem;
    }

    .dialog-body {
      display: flex;
      align-items: center;
      margin: 1.5rem 0 0;

      label {
        flex-basis: 13%;
        color: #333;
        font-weight: bolder;
        font-size: 1.25rem;
      }
    }

    .el-dialog__footer {
      padding: 0 1.25rem 2rem;
    }

    .el-dialog__headerbtn {
      right: 1.8rem;
    }
  }
}

@media screen and (max-width: 1200px) {
  .login {
    .login-bg {
      width: 48rem;
    }
  }
}
</style>
<style lang="scss">
.main-content {
  background-color: #fbf4ec !important;
}
</style>
