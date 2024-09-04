<template>
  <div class="reset-password">
    <!-- 我是重設密碼頁 -->
    <div class="reset-password-bg">
      <div v-loading="loading" class="reset-password-form">
        <h2 class="title">
          重設密碼
        </h2>
        <p class="prompt">
          密碼為8-12字元長度的英文字母以及數字混合字串
        </p>
        <el-form
          ref="ruleForm"
          :model="ruleForm"
          :rules="rules"
          label-width="100px"
          class="demo-ruleForm"
        >
          <el-form-item label="帳號" prop="user_id" margin-left="0">
            <el-input
              v-model="ruleForm.user_id"
              disabled
              :class="{ bg: ruleForm.user_id !== '' }"
              placeholder="請輸入帳號"
            />
          </el-form-item>
          <el-form-item label="新密碼" prop="newPassword">
            <el-input
              v-model="ruleForm.newPassword"
              show-password
              placeholder="請輸入新密碼"
            />
          </el-form-item>
          <el-form-item label="確認新密碼" prop="reNewPassword">
            <el-input
              v-model="ruleForm.reNewPassword"
              show-password
              placeholder="請再次輸入新密碼"
            />
          </el-form-item>
          <el-form-item class="user-login">
            <a @click="$router.push('/login')">用戶登入</a>
          </el-form-item>
          <el-form-item>
            <!-- <el-button class="btn" @click="validateRePassword('ruleForm')"> -->
            <el-button class="btn" @click="validateRePassword(ruleForm)">
              送&ensp;出
            </el-button>
          </el-form-item>
        </el-form>
      </div>
    </div>
  </div>
</template>
<script>
import backendApi from '@/assets/js/api/backendApi.js';

export default {
  data() {
    const validatePass = (rule, value, callback) => {
      const vm = this;
      const engReg = /[a-zA-Z]+/;
      const numReg = /\d+/;
      const marksReg = /\W+/;
      if (!engReg.test(value) || !numReg.test(value) || !marksReg.test(value)) {
        callback(new Error('密碼為8-12字元長度的符號、英文及數字混和字串'));
      } else if (vm.ruleForm.reNewPassword !== '') {
        vm.$refs.ruleForm.validateField('reNewPassword');
      }
      callback();
    };
    const validateRePass = (rule, value, callback) => {
      const vm = this;
      if (value !== vm.ruleForm.newPassword) {
        callback(new Error('兩次輸入密碼不一致!'));
      }
      callback();
    };
    return {
      loading: false,
      ruleForm: {
        user_id: '',
        code: '',
        newPassword: '',
        reNewPassword: '',
      },
      rules: {
        user_id: [
          {
            required: true,
            message: '請輸入帳號',
            trigger: 'blur',
          },
        ],
        newPassword: [
          {
            required: true,
            message: '请確認新密碼',
            trigger: 'blur',
          },
          {
            min: 8,
            max: 12,
            message: '密碼為8-12字元長度的符號、英文字母以及數字混合字串',
            trigger: 'blur',
          },
          {
            validator: validatePass,
            trigger: 'blur',
          },
        ],
        reNewPassword: [
          {
            required: true,
            message: '请再次確認新密碼',
            trigger: 'blur',
          },
          {
            validator: validateRePass,
            trigger: 'blur',
          },
        ],
      },
    };
  },
  mounted() {
    const vm = this;
    vm.ruleForm.user_id = vm.$route.query.account;
    vm.ruleForm.code = decodeURIComponent(vm.$route.query.resetPasswordId);
  },
  methods: {
    validateRePassword() {
      const vm = this;
      vm.$refs.ruleForm.validate((valid) => {
        if (valid) {
          vm.loading = true;
          vm.changePassword();
        }
      });
    },
    async changePassword() {
      const vm = this;
      const data = {
        newPassword: vm.ruleForm.newPassword,
        reNewPassword: vm.ruleForm.reNewPassword,
        userId: vm.ruleForm.user_id,
        code: vm.ruleForm.code,
      };
      const res = await backendApi.restPassword(data);
      if (res.code === 200) {
        vm.$message({
          message: '修改成功',
          type: 'success',
        });
        vm.loading = false;
        vm.$router.push('/login');
      } else {
        vm.loading = false;
      }
    },
  },
};
</script>
<style lang="scss" scoped>
.reset-password {
  padding: 10.5rem 0;
  font-family: Noto Sans CJK TC, sans-serif;
  background-color: #fbf4ec;

  .reset-password-bg {
    position: relative;
    width: 56.5rem;
    margin: 0 auto;
    border-radius: 10px;
    background-color: #fff;
    box-shadow: 7px 7px 7px #00000029;
  }

  .reset-password-form {
    width: 32rem;
    margin: 0 auto;
    padding: 4.6rem 0;
  }

  .title {
    margin-bottom: 1rem;
    color: #333;
    font-size: 1.625rem;
    //font-family: Noto Sans CJK TC, sans-serif;
    text-align: center;
  }

  .prompt {
    margin-bottom: 1rem;
    font-size: 1rem;
    letter-spacing: 2px;
  }

  /* 表單 */
  .bg {
    /deep/.el-input__inner {
      color: #5d5d5d;
      background-color: #b5b5b5;
    }
  }

  /deep/ .el-form-item {
    display: flex;
    align-items: center;
    margin-bottom: 22px;

    &:first-child {
      .el-form-item__label::before {
        display: none;
      }
    }
  }

  /deep/ .el-button {
    line-height: 1;
  }

  /deep/ .el-input {
    width: 100%;
  }

  /deep/ .el-form-item__label {
    flex-basis: 25%;
    padding: 0;
    color: #333;
    font-weight: bolder;
    font-size: 1.25rem;
    //font-family: Noto Sans CJK TC, sans-serif;
    text-align: left;
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
    // flex-basis: 75%;
    flex: 1;
    margin-left: 0 !important;
  }

  .user-login {
    margin: 0.8rem 0;
    text-align: right;

    /deep/.el-form-item__content {
      flex-basis: 100%;
    }

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
    padding: 1rem 0.75rem;
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
}

@media screen and (max-width: 768px) {
  .reset-password {
    padding: 1.5rem 0;

    .reset-password-bg {
      width: 21.5625rem;
    }

    .reset-password-form {
      width: 100%;
      padding: 1.875rem 1rem 1.5rem;
    }

    .title {
      margin-bottom: 1rem;
      font-size: 1.25rem;
    }

    .prompt {
      padding: 0 3.5rem;
      font-size: 0.875rem;
    }

    /deep/ .el-form-item {
      display: flex;
      flex-direction: column;
      align-items: left;
      margin-bottom: 1.5rem;
      // border: 1px solid red;
      text-align: left;

      &:nth-child(3) {
        margin-bottom: 0.3rem;
      }

      &:last-child {
        margin-bottom: 0;
      }

      .el-form-item__label {
        width: 100% !important;
        margin-bottom: 0.5rem;
        font-size: 1rem;
        line-height: 20px;
      }

      .el-form-item__content {
        width: 100%;

        .el-form-item__error {
          font-size: 0.8rem;
        }
      }
    }

    .user-login {
      margin: 0;
      margin-bottom: 1.875rem;
      text-align: right;

      a {
        font-size: 0.875rem;
      }
    }

    .btn {
      background-color: #ffa103;
    }
  }
}
</style>
