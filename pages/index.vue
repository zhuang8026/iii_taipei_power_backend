<template>
  <div class="home"  v-loading="loading">
    <div class="container">
      <div class="chart-info">
        <div class="chart">
          <h2>用戶連線狀態</h2>
          <div
            id="connection-status"
            @click="openDisconnectDialog"
          ></div>
          <p>更新時間 {{connectionUpdateTime}}</p>
        </div>
        <div class="chart" v-loading="loading">
          <h2>用戶登入次數</h2>
          <div id="login-num"></div>
          <p>更新時間 {{loginUpdateTime}}</p>
        </div>
      </div>
      <div class="user-info">
        <div class="item" @click="routerPush('userInfo')">
          <img
            :src="require('@/assets/img/pages/home/img-user-info.png')"
            alt=""
          />
          <h3>用戶資料</h3>
        </div>
        <div class="item" @click="routerPush('weeklyReport')">
          <img
            :src="require('@/assets/img/pages/home/img-weekly-report.png')"
            alt=""
          />
          <h3>週報紀錄</h3>
        </div>
        <!-- <div class="item" @click="routerPush('messageReport')">
          <img
            :src="require('@/assets/img/pages/home/img-message-record.png')"
            alt=""
          />
          <h3>簡訊紀錄</h3>
        </div> -->
        <div class="item" @click="changePasswordDialog=true">
          <img
            :src="require('@/assets/img/pages/home/change-password.png')"
            alt=""
          />
          <h3>變更密碼</h3>
        </div>
        <div class="item" @click="routerPush('download')">
          <img
            :src="require('@/assets/img/pages/home/img-info-download.png')"
            alt=""
          />
          <h3>資料下載</h3>
        </div>
        <div class="item" @click="routerPush('version')">
          <img
            :src="require('@/assets/img/pages/home/img-version-info.png')"
            alt=""
          />
          <h3>版本資訊</h3>
        </div>
        <div class="item" @click="routerPush('topic')">
          <img
            :src="require('@/assets/img/pages/home/img-issue-management.png')"
            alt=""
          />
          <h3>節電話題管理</h3>
        </div>
        <div class="item" @click="routerPush('questionnaire')">
          <img
            :src="require('@/assets/img/pages/home/img-questionnaire.png')"
            alt=""
          />
          <h3>問卷填寫紀錄</h3>
        </div>
      </div>
      <el-dialog
        title="用戶斷線狀況表單"
        :visible.sync="userDisconnectionStatus"
        v-loading="loading"
        class="disconnection-status"
        :before-close="closeDialog"
      >
        <el-table :data="disconnectionData" style="width: 100%;">
          <el-table-column prop="userId" label="用戶ID" width="350">
          </el-table-column>
          <el-table-column prop="updatetime" label="GW上次回傳資料" width="">
          </el-table-column>
        </el-table>
        <span slot="footer" class="dialog-footer">
          <el-pagination
          background
          layout="prev, pager, next"
          :total="totalElements"
          :page-size="size"
          :current-page.sync="currentPage"
          @current-change="handleCurrentChange"
        >
        </el-pagination>
        <el-button @click="getDisconnectionExcel">下載</el-button>
        </span>
      </el-dialog>
      <!--變更密碼彈窗-->
      <el-dialog title="變更密碼" :visible.sync="changePasswordDialog" center
      :before-close="closeEdit" class="change-password" v-loading="loading">
        <div class="form">
          <el-form
            :model="form"
            :rules="rules"
            ref="form"
            label-width="100px"
          >
            <el-form-item label="舊密碼" prop="oldPassword">
              <el-input
                show-password
                v-model="form.oldPassword"
                placeholder="請輸入原密碼"
              ></el-input>
            </el-form-item>
            <el-form-item label="新密碼" prop="newPassword">
              <el-input
                show-password
                v-model="form.newPassword"
                autocomplete="off"
                placeholder="請輸入新密碼"
              ></el-input>
            </el-form-item>
            <el-form-item label="確認密碼" prop="checkPassword">
              <el-input
                show-password
                v-model="form.checkPassword"
                autocomplete="off"
                placeholder="請再次輸入新密碼"
              ></el-input>
            </el-form-item>
          </el-form>
        </div>
        <span slot="footer" class="dialog-footer">
          <el-button @click="resetForm('form')">取消</el-button>
          <el-button @click="submit('form')"
            >變更密碼</el-button
          >
        </span>
      </el-dialog>
    </div>
    <div class="footer">
      <img :src="require('@/assets/img/pages/home/img-footer.png')" alt="" />
    </div>
  </div>
</template>

<script>
import backendApi from '@/assets/js/api/backendApi.js';
import helper from '@/assets/js/util/helper';
import { mapMutations } from 'vuex';

const echarts = require('echarts');

export default {
  data() {
    const validatenewPassword = (rule, value, callback) => {
      const vm = this;
      const engReg = /[a-zA-Z]+/;
      const numReg = /\d+/;
      const marksReg = /\W+/;
      // const reg = /^([a-zA-Z]+(\d+|\W+)|\d+([a-zA-Z]+|\W+)|\W+\w+)\S*$/;
      if (!engReg.test(value) || !numReg.test(value) || !marksReg.test(value)) {
        callback(new Error('密碼為8-12字元長度的符號、英文及數字混和字串'));
      } else if (value === vm.form.oldPassword) {
        callback(new Error('新密碼與原密碼相同'));
      } else if (vm.form.checkPassword !== '') {
        vm.$refs.form.validateField('reNewPassword');
      }
      callback();
    };
    const validatereNewPassword = (rule, value, callback) => {
      const vm = this;
      if (value !== vm.form.newPassword) {
        callback(new Error('新密碼不一致'));
      }
      callback();
    };
    return {
      testPrefix: 1,
      loading: false,
      changePasswordDialog: false,
      userDisconnectionStatus: false,
      // 斷線狀況表
      disconnectionData: [
      ],
      // 斷線狀況表頁數
      totalPages: 1,
      totalElements: 0,
      currentPage: 1,
      size: 20,
      // 變更密碼表
      form: {
        oldPassword: '',
        newPassword: '',
        checkPassword: '',
      },
      rules: {
        oldPassword: [
          { required: true, message: '請輸入原密碼', trigger: 'blur' },
          // {
          //   validator: validateoldPassword,
          //   trigger: 'blur',
          // },
        ],
        newPassword: [
          { required: true, message: '請輸入新密碼', trigger: 'blur' },
          {
            validator: validatenewPassword,
            trigger: 'blur',
          },
        ],
        checkPassword: [
          { required: true, message: '請再次輸入新密碼', trigger: 'blur' },
          {
            validator: validatereNewPassword,
            trigger: 'blur',
          },
        ],
      },

      loginPieData: {}, // 登入次數資料
      loginUpdateTime: '', // 登入次數更新時間
      connectionPieData: {}, // 連線狀態資料
      connectionUpdateTime: '', // 連線狀態更新時間
    };
  },
  async mounted() {
    const vm = this;
    // vm.$nextTick(() => {
    //   vm.connectionPie('connection-status');
    // });
    // vm.$nextTick(() => {
    //   vm.loginPie('login-num');
    // });
    await Promise.all([vm.getLoginPieChartData(), vm.getConnectionPieChartData()]);
    // await Promise.all([vm.getLoginPieChartData(), vm.getConnectionPieChartData(), vm.getDisconnectionList(vm.currentPage)]);
  },

  methods: {
    ...mapMutations('user', ['CLEAR_USER_DATA']),
    // 連線狀態圓餅圖
    connectionPie(id) {
      const vm = this;
      vm.charts = echarts.init(document.getElementById(id));
      vm.charts.setOption({
        color: ['#FFBA31', '#FFEDCA'] /* 圓餅圖的颜色 */,
        tooltip: {
          trigger: 'item',
          formatter: '{b}({d}%)', /* 指向圓餅圖顯示的注釋文字 */
        },
        legend: {
          // left: 'center', /* 標籤文字排成一行 */
          orient: 'vertical',
          bottom: '3%' /* 在垂直方向上的底部 */,
          left: 'center',
          // data: vm.opinion,
          itemGap: 10, // 圖示間距
          itemWidth: 16,
          itemHeight: 16,
          textStyle: {
            fontSize: 16,
            fontFamily: 'Noto Sans CJK TC, sans-serif',
            color: '#7A7A7A',
          },
          formatter: (name) => {
            const series = vm.charts.getOption().series[0];
            const { value } = series.data.filter((row) => row.name === name)[0];
            return `${name}   ${value}   戶`;
          },
        },
        series: [
          {
            type: 'pie', // 圓餅圖
            center: ['50%', '40%'], // 顯示位置
            name: '',
            itemStyle: {
              emphasis: {
                shadowBlur: 10,
                shadowOffsetX: 0,
                shadowColor: 'rgba(0, 0, 0, 0.5)',
              },
            },

            avoidLabelOverlap: false,
            label: {
              show: false,
            },
            // data: vm.opinionData,
            data: [
              {
                value: Object.keys(vm.connectionPieData).length ? vm.connectionPieData.loginNumber : '',
                name: '連線',
                label: {
                  color: '#318CAB',
                },
              },
              {
                value: Object.keys(vm.connectionPieData).length ? vm.connectionPieData.logoutNumber : '',
                name: '離線',
                label: {
                  color: '#D4A610',
                },
              },
            ],
          },
        ],
      });
    },
    // 登入次數圓餅圖
    loginPie(id) {
      const vm = this;
      vm.charts = echarts.init(document.getElementById(id));
      vm.charts.setOption({
        color: ['#FFBA31', '#FFEDCA'] /* 圓餅圖的颜色 */,
        tooltip: {
          trigger: 'item',
          formatter: '{b}({d}%)', /* 指向圓餅圖顯示的注釋文字 */
        },
        legend: {
          // left: 'center', /* 標籤文字排成一行 */
          orient: 'vertical',
          bottom: '3%' /* 在垂直方向上的底部 */,
          right: 'center',
          // data: vm.opinion,
          itemGap: 10, // 圖示間距
          itemWidth: 15,
          textStyle: {
            fontSize: 16,
            fontFamily: 'Noto Sans CJK TC, sans-serif',
            color: '#7A7A7A',
          },
          formatter: (name) => {
            const series = vm.charts.getOption().series[0];
            const { value } = series.data.filter((row) => row.name === name)[0];
            return `${name}    ${value}    次`;
          },
        },
        series: [
          {
            type: 'pie', // 圓餅圖
            center: ['50%', '40%'], // 顯示位置
            name: '',
            itemStyle: {
              emphasis: {
                shadowBlur: 10,
                shadowOffsetX: 0,
                shadowColor: 'rgba(0, 0, 0, 0.5)',
              },
            },

            avoidLabelOverlap: false,
            label: {
              show: false,
            },
            data: [
              {
                value: Object.keys(vm.loginPieData).length ? vm.loginPieData.monthLoginNumber : '',
                name: '本月',
                label: {
                  color: '#318CAB',
                },
              },
              {
                value: Object.keys(vm.loginPieData).length ? vm.loginPieData.yesterdayLoginNumber : '',
                name: '昨日',
                label: {
                  color: '#D4A610',
                },
              },
            ],
          },
        ],
      });
    },

    // 變更密碼 dialog
    async changePassword() {
      const vm = this;
      const obj = {
        oldPassword: vm.form.oldPassword,
        newPassword: vm.form.newPassword,
        reNewPassword: vm.form.checkPassword,
      };
      vm.loading = true;
      const res = await backendApi.changePassword(obj);
      if (res.code === 200) {
        vm.$message({
          message: '變更密碼成功，請重新登入',
          type: 'success',
        });
        vm.loading = false;
        vm.resetForm('form');
        vm.CLEAR_USER_DATA();
        vm.$router.push('/login');
      } else {
        vm.loading = false;
      }
    },
    // 關變更密碼dialog之前資料重置
    closeEdit(done) {
      const vm = this;
      vm.$refs.form.resetFields();
      done();
    },
    cancel() {
      const vm = this;
      vm.$refs.form.resetFields();
      vm.changePasswordDialog = false;
    },
    submit() {
      const vm = this;
      vm.$refs.form.validate((valid) => {
        if (valid) {
          vm.changePassword();
        }
      });
    },
    routerPush(path) {
      const vm = this;
      vm.$router.push(`/${path}`);
    },
    resetForm(formName) {
      const vm = this;
      vm.$refs[formName].resetFields();
      vm.changePasswordDialog = false;
    },

    // 取得登入次數圓餅圖資料
    async getLoginPieChartData() {
      const vm = this;
      const res = await backendApi.getLoginPieChart();
      if (res.code === 200) {
        // console.log('GET PIE');
        vm.loginPieData = res.data;
        vm.loginUpdateTime = helper.transformTime(res.data.updateDate, 1);
      }
      vm.loginPie('login-num');
    },
    // 取得連線狀態圓餅圖資料
    async getConnectionPieChartData() {
      const vm = this;
      vm.loading = true;
      const res = await backendApi.getConnectionPieChart();
      if (res.code === 200) {
        // console.log('GET CONNECTION PIE');
        vm.connectionPieData = res.data;
        vm.connectionUpdateTime = helper.transformTime(res.data.updateDate, 1);
      }
      vm.connectionPie('connection-status');
      vm.loading = false;
    },

    openDisconnectDialog() {
      const vm = this;
      vm.userDisconnectionStatus = true;
      vm.getDisconnectionList(vm.currentPage);
    },

    // 取得斷線列表
    async getDisconnectionList(page) {
      const vm = this;
      vm.loading = true;
      const obj = {
        page,
        size: vm.size,
      };
      const res = await backendApi.getDisconnectionList(obj);
      if (res.code === 200) {
        // console.log('GET DisconnectionList');
        res.data.content.forEach((item) => {
          item.updatetime = helper.transformTime(item.updatetime, 1);
        });
        vm.disconnectionData = res.data.content;
        vm.totalElements = res.data.totalElements;
        vm.totalPages = res.data.totalPages;
      }
      vm.loading = false;
    },
    // 分頁切換
    handleCurrentChange(page) {
      const vm = this;
      vm.currentPage = page;
      vm.getDisconnectionList(vm.currentPage);
    },
    closeDialog(done) {
      const vm = this;
      vm.currentPage = 1;
      done();
    },

    // 取得斷線列表Excel
    async getDisconnectionExcel() {
      // const vm = this;
      const res = await backendApi.getDisconnectionExcel();
      if (res) {
        const a = document.createElement('a');
        const blob = new Blob([res], { type: 'application/excel' });
        a.href = window.URL.createObjectURL(blob);
        a.download = '用戶斷線狀況表.xlsx';
        a.style.display = 'none';
        document.body.appendChild(a);
        a.click();
      }
    },
  },
};
</script>
<style lang="scss" scoped>
.home {
  position: relative;
  height: 100%;
  background-color: #fbf4ec;

  .container {
    display: flex;
    width: fit-content;
    margin: auto;
    padding: 5rem 0;
  }

  /** 圖表區 */
  .chart-info {
    display: grid;
    flex-basis: 35%;
    grid-gap: 3rem;
    grid-template-rows: repeat(2, 20.6rem);
    grid-template-columns: repeat(1, 34rem);
    margin-right: 2.5rem;

    .chart {
      display: flex;
      flex-direction: column;
      align-items: center;
      border-radius: 0.625rem;
      background-color: #fff;
      box-shadow: 5px 5px 10px #00000029;

      h2 {
        margin-top: 1.5rem;
        //margin-bottom: 1rem;
        text-align: center;
      }

      #connection-status,
      #login-num {
        width: 12rem;
        height: 15rem;
      }

      p {
        color: #7a7a7a;
        font-size: 0.875rem;
        font-family: Noto Sans CJK TC, sans-serif;
        letter-spacing: 0.05rem;
      }
    }
  }

  /** 使用者區 */
  .user-info {
    z-index: 1;
    display: grid;
    flex-basis: 65%;
    grid-gap: 4rem 2.5rem;
    grid-template-rows: repeat(3, 12rem);
    grid-template-columns: repeat(3, 16.5rem);

    .item {
      display: flex;
      flex-direction: column;
      align-items: center;
      padding: 2rem 4rem 1rem;
      border-radius: 0.625rem;
      background-color: #fff;
      box-shadow: 5px 5px 10px #00000029;
      cursor: pointer;

      img {
        width: 5rem;
        object-fit: cover;
      }

      h3 {
        margin-top: 1.5rem;
      }
    }
  }

  /** footer */
  .footer {
    position: absolute;
    bottom: 3%;
    width: 100%;
    height: 12.4vw;
    pointer-events: none;

    img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }
  }

  /** dialog */
  /deep/ .el-dialog {
    //width: 43.75rem;
    width: 50rem;

    .el-dialog__body {
      padding: 0 4.25rem 1.875rem;
    }

    .el-button:nth-child(1) {
      border-color: #ffd081;
      background-color: #ffd081;

      &:hover {
        border-color: #ffa103;
        background-color: #ffa103;
      }
    }

    .el-dialog__footer {
      padding: 0.625rem 1.25rem 2.25rem;
    }
  }

  .disconnection-status {
    // /deep/ .dialog-footer {
    //   display: flex;
    // }

    /deep/ .el-dialog__footer {
      padding: 0.625rem 4.25rem 2.25rem;
    }

    /deep/ .el-pagination {
      margin-top: 0.5rem;
      margin-right: 1rem;
      margin-bottom: 1.5rem;
    }
  }

  /** table */
  /deep/ .el-table {
    border: 1px solid #23354d;
    border-radius: 10px;

    th {
      padding: 1.025rem 0;
    }

    th.el-table_1_column_1 {
      border-right: 0.0625rem solid #23354d;
    }

    th.is-leaf {
      border-color: #23354d;
      border-bottom: 0.0625rem solid #23354d;
    }

    td {
      padding: 1.025rem 0;
      border-color: #23354d;
      border-bottom: 0.0625rem solid #23354d;
      background-color: #fff;
    }

    td.el-table_1_column_1 {
      border-right: 0.0625rem solid #23354d;
    }

    .el-table .cell,
    .el-table th > .cell {
      padding-left: 2.45rem;
    }

    tr:last-child {
      td {
        border-bottom: unset;
      }
    }
  }

  /** 更換密碼dialog */
  .change-password {
    /deep/ .el-dialog .el-dialog__header {
      padding: 2.225rem 1.25rem 1.5rem;
    }

    /deep/ .el-form {
      width: 25rem;
      margin: auto;
    }

    /deep/ .el-form-item {
      display: flex;
      flex-direction: column;
      margin-bottom: 1rem;
      margin-left: 0 !important;
    }

    /deep/ .el-form-item__label {
      width: 8rem !important;
      text-align: left;
    }

    /deep/ .el-form-item__content {
      margin-left: 0 !important;
    }

    /deep/ .el-input {
      position: relative;
      width: 100%;
    }

    /deep/ .el-input__inner {
      border: 1px solid #23354d;
      color: #b5b5b5;
      font-size: 1.125rem;
      letter-spacing: 0.1rem;
    }

    /deep/ .el-form-item__error {
      padding-top: 0.45rem;
    }

    /deep/ .el-dialog .el-button:nth-child(1) {
      background-color: #b5b5b5;
    }

    /deep/ .el-dialog .el-button {
      width: 12rem;
    }
  }
}

@media screen and(max-width: 1500px) {
  .home {
    .container {
      padding: 5rem 0 9rem;
    }

    .chart-info {
      grid-template-rows: repeat(2, 19.55rem);
      grid-template-columns: repeat(1, 30rem);

      .chart {
        h2 {
          margin-top: 0.7rem;
        }
      }
    }

    .user-info {
      grid-gap: 3rem;
      grid-template-rows: repeat(4, 12rem);
      grid-template-columns: repeat(2, 18rem);

      .item {
        padding: 2rem 4.5rem 1rem;

        img {
          width: 5rem;
        }
      }
    }
  }
}

@media screen and (max-width: 1200px) {
  .home {
    .chart-info {
      grid-template-columns: repeat(1, 25rem);
    }

    .user-info {
      grid-gap: 3rem 2.5rem;
      grid-template-columns: repeat(2, 15rem);

      .item {
        padding: 2rem 1.5rem 1rem;

        img {
          width: 4.5rem;
        }
      }
    }
  }
}
</style>
