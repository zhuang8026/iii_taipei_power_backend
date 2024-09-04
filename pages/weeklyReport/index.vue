<template>
  <div class="weekly-report" v-loading="loading">
    <w-layout>
      <template #header-text>週報紀錄</template>
      <template #filter>
        <el-form
          :model="searchForm"
          :rules="rules"
          ref="searchForm"
          class="demo-ruleForm"
        >
          <el-form-item label="查詢區間：" prop="searchTime">
            <el-date-picker
              v-model="searchForm.searchTime"
              type="month"
              placeholder="請選擇月份"
              format="yyyy/MM"
              value-format="yyyy-MM"
              :editable="false"
            >
            </el-date-picker>
          </el-form-item>
          <div class="btn-list">
            <el-button @click="search">查詢</el-button>
            <el-button @click="clear" class="btn-clear">清空</el-button>
            <el-button @click="openDownloadDialog">下載</el-button>
            <el-button @click="openSettingDialog" class="setting-btn"
              >寄送排程設定</el-button
            >
          </div>
        </el-form>
      </template>

      <div class="container" v-if="tableData.length">
        <el-table
          :data="tableData"
          stripe
          style="width: 100%;"
          v-loading="loading"
        >
          <el-table-column prop="userNmae" label="姓名" min-width="50%">
          </el-table-column>
          <!-- <el-table-column prop="userId" label="電子郵件" width="350">
          </el-table-column> -->
          <el-table-column
            :label="`週報 ${weekRangeData.week1}`"
            min-width="80%"
          >
            <template slot-scope="scope">
              <img
                v-if="scope.row.weekRange1 && scope.row.weekMailTime1"
                :src="require(`@/assets/img/common/icon-check-circle.svg`)"
              />
              <p v-else class="dashed">-</p>
            </template>
          </el-table-column>
          <el-table-column
            :label="`週報 ${weekRangeData.week2}`"
            min-width="80%"
          >
            <template slot-scope="scope">
              <img
                v-if="scope.row.weekRange2 && scope.row.weekMailTime2"
                :src="require(`@/assets/img/common/icon-check-circle.svg`)"
              />
              <p v-else class="dashed">-</p>
            </template>
          </el-table-column>
          <el-table-column
            :label="`週報 ${weekRangeData.week3}`"
            min-width="80%"
          >
            <template slot-scope="scope">
              <img
                v-if="scope.row.weekRange3 && scope.row.weekMailTime3"
                :src="require(`@/assets/img/common/icon-check-circle.svg`)"
              />
              <p v-else class="dashed">-</p>
            </template>
          </el-table-column>
          <el-table-column
            :label="`週報 ${weekRangeData.week4}`"
            min-width="80%"
          >
            <template slot-scope="scope">
              <img
                v-if="scope.row.weekRange4 && scope.row.weekMailTime4"
                :src="require(`@/assets/img/common/icon-check-circle.svg`)"
              />
              <p v-else class="dashed">-</p>
            </template>
          </el-table-column>
          <el-table-column
            :label="`週報 ${weekRangeData.week5}`"
            min-width="80%"
            v-if="weekRangeData.week5"
          >
            <template slot-scope="scope">
              <img
                v-if="scope.row.weekRange5 && scope.row.weekMailTime5"
                :src="require(`@/assets/img/common/icon-check-circle.svg`)"
              />
              <p v-else class="dashed">-</p>
            </template>
          </el-table-column>
          <el-table-column :label="`月報 ${weekRangeData.month}`">
            <template slot-scope="scope">
              <img
                v-if="scope.row.monRange && scope.row.monMailTime"
                :src="require(`@/assets/img/common/icon-check-circle.svg`)"
              />
              <p v-else class="dashed">-</p>
            </template>
          </el-table-column>
        </el-table>
        <el-pagination
          background
          layout="prev, pager, next"
          :total="totalElements"
          :page-size="size"
          :current-page.sync="currentPage"
          @current-change="handleCurrentChange"
        >
        </el-pagination>
      </div>
      <!-- 下載週報紀錄 -->
      <el-dialog
        title="週報紀錄"
        :visible.sync="reportDownloadDialog"
        center
        class="report-dialog"
        :before-close="closeEdit"
        v-if="reportDownloadDialog"
      >
        <div class="btn-list">
          <el-button
            plain
            size="medium"
            class="btn-month"
            :class="{ 'is-active': tab.active }"
            @click="changeTab(tab)"
            v-for="(tab, index) in tabList"
            :key="index"
          >
            {{ tab.tabName }}
          </el-button>
        </div>
        <div class="list">
          <!--單月-->
          <div class="block single-month" v-show="tabList[0].active">
            <el-form
              :model="singleMonthForm"
              :rules="singleMonthFormRules"
              ref="singleMonthForm"
              class="demo-ruleForm"
            >
              <el-form-item label="月份：" prop="month">
                <el-date-picker
                  v-model="singleMonthForm.month"
                  type="month"
                  placeholder="請選擇月份"
                  format="yyyy/MM"
                  value-format="yyyy-MM"
                  :editable="false"
                >
                </el-date-picker>
              </el-form-item>
            </el-form>
          </div>
          <!--區間-->
          <div class="block range-month" v-show="tabList[1].active">
            <el-form
              :model="monthRangeForm"
              :rules="monthRangeFormRules"
              ref="monthRangeForm"
              class="demo-ruleForm"
            >
              <el-form-item label="月份：" prop="startMonth">
                <el-date-picker
                  v-model="monthRangeForm.startMonth"
                  type="month"
                  placeholder="請選擇月份"
                  format="yyyy/MM"
                  value-format="yyyy-MM"
                  :editable="false"
                  :picker-options="setStartMonth"
                >
                </el-date-picker>
              </el-form-item>
              <span class="text">至</span>
              <el-form-item label="" prop="endMonth">
                <el-date-picker
                  v-model="monthRangeForm.endMonth"
                  type="month"
                  placeholder="請選擇月份"
                  format="yyyy/MM"
                  value-format="yyyy-MM"
                  :editable="false"
                  :picker-options="setEndMonth"
                >
                </el-date-picker>
              </el-form-item>
            </el-form>
          </div>
        </div>
        <span slot="footer" class="dialog-footer">
          <el-button @click="reportDownloadDialog = false">取消</el-button>
          <el-button type="primary" @click="download">下載</el-button>
        </span>
      </el-dialog>

      <!-- 排程設定 -->
      <el-dialog
        title="排程設定"
        :visible.sync="settingDialog"
        center
        class="setting-dialog"
        v-if="settingDialog"
      >
        <div class="btn-list">
          <el-button
            plain
            size="medium"
            class="btn-month"
            :class="{ 'is-active': type.active }"
            @click="changeType(type)"
            v-for="(type, index) in typeList"
            :key="index"
            v-model="editData.reportType"
          >
            {{ type.typeName }}
          </el-button>
        </div>
        <div class="setting-container">
          <!--週報-->
          <div class="block" v-show="typeList[0].active">
            <p class="mark">每週</p>
            <el-select v-model="editData.weekSelect" size="small">
              <el-option
                v-for="(day, index) in weekdays"
                :key="index"
                :label="day.label"
                :value="day.value"
              >
              </el-option>
            </el-select>
            <p class="mark">寄週報</p>
          </div>
          <!--月報-->
          <div class="block" v-show="typeList[1].active">
            <p class="mark">每月</p>
            <el-select v-model="editData.select" size="small">
              <el-option
                v-for="(n, index) in 28"
                :key="index"
                :value="n"
              >
              </el-option>
            </el-select>
            <p class="mark">號寄月報</p>
          </div>
        </div>
        <span slot="footer" class="dialog-footer">
          <el-button @click="settingDialog = false">取消</el-button>
          <el-button type="primary" @click="editSchedule"
            >確定</el-button
          >
        </span>
      </el-dialog>
    </w-layout>
  </div>
</template>
<script>
import WLayout from '@/components/Layout';
import backendApi from '@/assets/js/api/backendApi.js';
import dayjs from 'dayjs';
// import helper from '@/assets/js/util/helper';

export default {
  components: {
    WLayout,
  },
  data() {
    return {
      tabName: '單月',
      tabList: [
        {
          id: 1,
          tabName: '單月',
          active: true,
        },
        {
          id: 2,
          tabName: '區間',
          active: false,
        },
      ],
      loading: false,
      tableData: [], // 週報列表
      weekRangeData: [], // 時間範圍

      searchForm: {
        searchTime: '', // 搜尋條件
      },
      rules: {
        searchTime: [
          {
            required: true,
            message: '請選擇月份',
            trigger: 'blur',
          },
        ],
      },
      currentMonth: '', // 存取選擇月份
      reportDownloadDialog: false, // 下載Excel彈窗

      // 下載Execel
      singleMonthForm: {
        month: '', // 單一月份
      },
      singleMonthFormRules: {
        month: [
          {
            required: true,
            message: '請選擇月份',
            trigger: 'blur',
          },
        ],
      },
      monthRangeForm: {
        startMonth: '', // 起始月份
        endMonth: '', // 結束月份
      },
      monthRangeFormRules: {
        startMonth: [
          {
            required: true,
            message: '請選擇月份',
            trigger: 'blur',
          },
        ],
        endMonth: [
          {
            required: true,
            message: '請選擇月份',
            trigger: 'blur',
          },
        ],
      },
      setStartMonth: {
        disabledDate: (time) => {
          if (!this.monthRangeForm.endMonth) {
            return time.getTime() < new Date(1970 - 1 - 1).getTime(); // 禁止選擇1970年以前的日期
          }
          return time.getTime() > new Date(this.monthRangeForm.endMonth);
        },
      },
      setEndMonth: {
        disabledDate: (time) => time.getTime() < new Date(this.monthRangeForm.startMonth)
          || time.getTime() < new Date(1970 - 1 - 1).getTime(), // 禁止選擇1970年以前的日期
      },

      // 頁數
      totalPages: 1,
      totalElements: 0,
      currentPage: 1,
      size: 20,

      // 排程設定
      settingDialog: false,
      typeList: [
        {
          id: 1,
          value: 0,
          typeName: '週報',
          active: true,
        },
        {
          id: 2,
          value: 1,
          typeName: '月報',
          active: false,
        },
      ],
      weekdays: [
        { code: 'MON', label: '一', value: 1 },
        { code: 'TUE', label: '二', value: 2 },
        { code: 'WED', label: '三', value: 3 },
        { code: 'THU', label: '四', value: 4 },
        { code: 'FRI', label: '五', value: 5 },
        { code: 'SAT', label: '六', value: 6 },
        { code: 'SUN', label: '日', value: 7 },
      ],
      select: 5, // 預設每月幾號寄月報
      weekSelect: 2, // 預設每週幾寄週報
      reportType: 0,
      reportTypeName: '週報',
      editData: {
        select: 5, // 每月幾號寄月報
        weekSelect: 2, // 每週幾寄週報
        reportType: 0,
      },
    };
  },
  async mounted() {
    const vm = this;
    // vm.getWeeklyExcel();
    vm.searchForm.searchTime = dayjs().format('YYYY-MM');
    vm.currentMonth = vm.searchForm.searchTime;
    await Promise.all([vm.getAllData(vm.currentPage)]);
  },
  methods: {
    dayjs,
    clear() {
      const vm = this;
      vm.$refs.searchForm.resetFields();
      vm.currentPage = 1;
      vm.currentMonth = dayjs().format('YYYY-MM');
      vm.searchForm.searchTime = dayjs().format('YYYY-MM');
      vm.getAllData(vm.currentPage);
    },
    search() {
      const vm = this;
      vm.$refs.searchForm.validate((valid) => {
        if (valid) {
          vm.loading = true;
          vm.currentPage = 1;
          vm.currentMonth = vm.searchForm.searchTime;
          vm.getAllData(vm.currentPage);
        }
      });
    },
    openDownloadDialog() {
      const vm = this;
      vm.reportDownloadDialog = true;
      vm.tabList[0].active = true;
      vm.tabList[1].active = false;
      vm.tabName = '單月';
      vm.monthRangeForm.startMonth = '';
      vm.monthRangeForm.endMonth = '';
      vm.singleMonthForm.month = '';
      // vm.$refs.singleMonthForm.resetFields();
      // vm.$refs.monthRangeForm.resetFields();
    },
    closeEdit(done) {
      const vm = this;
      vm.$refs.singleMonthForm.resetFields();
      vm.$refs.monthRangeForm.resetFields();
      vm.tabList[0].active = true;
      vm.tabList[1].active = false;
      done();
    },
    singleMonthFormValidate() {
      const vm = this;
      vm.$refs.singleMonthForm.validate((valid) => {
        if (valid) {
          // vm.loading = true;
          vm.getWeeklyExcel();
          // console.log('單月測試');
        }
      });
    },
    monthRangeFormValidate() {
      const vm = this;
      vm.$refs.monthRangeForm.validate((valid) => {
        if (valid) {
          // vm.loading = true;
          vm.getWeeklyExcel();
          // console.log('區間測試');
        }
      });
    },
    // 打開排程設定彈窗
    openSettingDialog() {
      const vm = this;
      vm.settingDialog = true;
      vm.typeList[0].active = true;
      vm.typeList[1].active = false;
      vm.reportTypeName = vm.typeList[0].typeName;
      vm.reportType = vm.typeList[0].value;
      vm.editData.reportType = vm.typeList[0].value;
    },

    // 取得所有週報列表
    async getAllData(page) {
      const vm = this;
      vm.loading = true;
      const obj = {
        month: vm.currentMonth,
        page,
        size: vm.size,
      };

      const res = await backendApi.getWeeklyList(obj);
      if (res.code === 200) {
        // console.log('GET ALL');
        vm.weekRangeData = res.data.weekRange;
        vm.tableData = res.data.monthPage.content;
        vm.totalElements = res.data.monthPage.totalElements;
        vm.totalPages = res.data.monthPage.totalPages;
      } else {
        vm.$message({
          message: res.message,
          type: 'error',
        });
      }
      vm.loading = false;
      // console.log(vm.tableData);
    },

    // 切換單月、區間
    changeTab(tab) {
      const vm = this;
      if (tab.tabName === '單月') {
        vm.tabName = tab.tabName;
        vm.tabList[0].active = true;
        vm.tabList[1].active = false;
        vm.singleMonthForm.month = '';
        vm.$refs.singleMonthForm.resetFields();
      } else if (tab.tabName === '區間') {
        vm.tabName = tab.tabName;
        vm.tabList[0].active = false;
        vm.tabList[1].active = true;
        vm.monthRangeForm.startMonth = '';
        vm.monthRangeForm.endMonth = '';
        vm.$refs.monthRangeForm.resetFields();
      }
    },
    // 切換排程設定的週報、月報
    changeType(type) {
      const vm = this;
      if (type.typeName === '週報') {
        vm.reportTypeName = type.typeName;
        vm.reportType = type.value;
        vm.editData.reportType = type.value;
        vm.typeList[0].active = true;
        vm.typeList[1].active = false;
        // vm.singleMonthForm.month = '';
        // vm.$refs.singleMonthForm.resetFields();
      } else if (type.typeName === '月報') {
        vm.reportTypeName = type.typeName;
        vm.reportType = type.value;
        vm.editData.reportType = type.value;
        vm.typeList[0].active = false;
        vm.typeList[1].active = true;
        // vm.monthRangeForm.startMonth = '';
        // vm.monthRangeForm.endMonth = '';
        // vm.$refs.monthRangeForm.resetFields();
      }
    },
    // 取得週報Excel
    download() {
      const vm = this;
      if (vm.tabName === '單月') {
        vm.singleMonthFormValidate();
      } else if (vm.tabName === '區間') {
        vm.monthRangeFormValidate();
      }
    },
    async getWeeklyExcel() {
      const vm = this;
      let data = {};
      let res;
      let excelTitle = '';
      if (vm.tabName === '單月') {
        data = {
          startMonth: vm.singleMonthForm.month,
          endMonth: vm.singleMonthForm.month,
        };
        res = await backendApi.getWeeklyExcel(data);
        excelTitle = `${vm.singleMonthForm.month} 週報.xlsx`;
      } else if (vm.tabName === '區間') {
        data = {
          startMonth: vm.monthRangeForm.startMonth,
          endMonth: vm.monthRangeForm.endMonth,
        };
        res = await backendApi.getWeeklyExcel(data);
        excelTitle = `${vm.monthRangeForm.startMonth} 至 ${vm.monthRangeForm.endMonth} 週報.xlsx`;
      }
      // console.log(data);
      if (res && res.byteLength > 1000) {
        const a = document.createElement('a');
        const blob = new Blob([res], { type: 'application/excel' });
        a.href = window.URL.createObjectURL(blob);
        a.download = excelTitle;
        a.style.display = 'none';
        document.body.appendChild(a);
        a.click();
      } else {
        // const stringRes = String.fromCharCode.apply(null, new Uint8Array(res));
        // const objRes = JSON.parse(stringRes);
        // console.log(stringRes);
        // console.log(objRes);
        vm.$message({
          message: '資料不存在 (Error, data not found.)',
          type: 'error',
        });
      }
    },

    // 分頁切換
    handleCurrentChange(page) {
      const vm = this;
      vm.currentPage = page;
      vm.getAllData(vm.currentPage);
    },

    // 排程設定
    async editSchedule() {
      const vm = this;
      let obj = {};
      if (vm.reportTypeName === '週報') {
        obj = {
          reportType: vm.editData.reportType,
          weeklyCron: vm.editData.weekSelect,
        };
      } else if (vm.reportTypeName === '月報') {
        obj = {
          reportType: vm.editData.reportType,
          MonthlyCron: vm.editData.select,
        };
      }
      const res = await backendApi.editSchedule(obj);
      if (res.code === 200) {
        vm.settingDialog = false;
      }
    },
  },
};
</script>
<style lang="scss" scoped>
.weekly-report {
  /deep/
  .el-form-item.is-required:not(.is-no-asterisk) > .el-form-item__label::before {
    display: none;
  }

  .setting-btn {
    padding: 0 1.25rem;
    background-color: #67bcc2;
  }

  /** 單月、區間切換按鈕 */
  .report-dialog {
    /deep/ .el-dialog__body {
      padding: 1.5625rem 11.7625rem 1.875rem;
    }

    .btn-list {
      display: flex;
      width: 20rem;
      margin: auto;

      .el-button {
        position: unset;
        width: 100%;
        border: 2px solid #ffba31;
        border-radius: unset;
        color: #ffba31;
        background-color: #fff;

        &:active {
          border-color: #ffba31;
          color: #ffba31;
          background-color: #ffba31;
        }
      }

      .el-button + .el-button {
        margin-left: 0;
      }

      .is-active {
        color: #fff;
        background-color: #ffba31;
      }
    }

    .list {
      margin-top: 2rem;

      .block {
        display: flex;
        flex-direction: column;
        //width: 20rem;
        margin: auto;

        span {
          margin-bottom: 1rem;
          color: #333;
          font-weight: bolder;
          font-size: 1.275rem;
          font-family: Noto Sans CJK TC, sans-serif;
        }

        /deep/ .el-date-editor.el-input {
          width: 100%;
          border-color: #b5b5b5;
        }

        /deep/ .el-input__inner {
          padding-left: 2.675rem;
          border-color: #b5b5b5;
          color: #949494;
          font-size: 1.125rem;
          letter-spacing: 0.1rem;
          cursor: pointer;
        }

        /deep/ .el-input__icon {
          width: 1.0625rem;
          background-image: url('~@/assets/img/common/icon-calendar.svg');
          background-repeat: no-repeat;
          background-size: contain;
        }

        /deep/ .el-icon-date::before {
          content: '';
        }

        /deep/ .el-input__prefix {
          top: 0.9rem;
          left: 0.9125rem;
        }

        /deep/ .el-icon-circle-close {
          display: none;
        }
      }

      .range-month {
        .text {
          display: block;
          margin-top: 1rem;
          font-size: 1.2rem;
          text-align: center;
        }

        /deep/ .el-form {
          display: block;
        }

        /deep/ .el-form-item {
          display: block;
          margin-right: 0;
        }
      }

      .single-month {
        /deep/ .el-form {
          display: block;
        }

        /deep/ .el-form-item {
          display: block;
          margin-right: 0;
        }
      }
    }
  }

  /** el form 樣式(不包含彈窗) */
  /deep/ .el-form {
    display: flex;

    .el-form-item {
      display: flex;
      align-items: center;
      margin-right: 1.3rem;
    }
  }

  /** el table 樣式 */
  /deep/ .el-table {
    border: 1px solid #b5b5b5;

    th:first-child .cell {
      padding-left: 1.75rem;
    }

    th.is-leaf {
      border-bottom: 0.0625rem solid #707070;
      border-left: 0.0625rem solid #b5b5b5;
    }

    th:first-child {
      border-left: unset;
    }

    td {
      padding: 0.425vw 0;
      border-left: 0.0625rem solid #b5b5b5;

      &:first-child {
        border-left: unset;
      }

      .cell {
        color: #787878;
        font-size: 1rem;
        font-family: Noto Sans CJK TC, sans-serif;
        letter-spacing: 0.15rem;

        img {
          display: block;
          width: 2vw;
          margin: auto;
        }

        .dashed {
          padding: 0.46rem 0;
          text-align: center;
        }
      }
    }

    td:first-child .cell {
      padding-left: 1.75rem;
    }
  }

  /** el pagination */
  /deep/ .el-pager li {
    min-width: 2.175rem;
    height: 2.2rem;
    padding: 0 0.6rem;
    line-height: 2.2rem;
  }

  /deep/ .el-pagination button {
    min-width: 2.175rem;
    height: 2.2rem;
    line-height: 2.2rem;
  }

  .btn-clear {
    border: 1px solid #ccc;
    background-color: #ccc;
  }

  .btn-clear:hover {
    border: 1px solid #949494;
    background-color: #949494;
  }

  /** 排程設定彈窗 */
  .setting-dialog {
    /deep/ .el-dialog__body {
      padding: 1.5625rem 7.7625rem 1.875rem;
    }

    /deep/ .el-dialog__header {
      padding: 2.225rem 1.25rem 0.3rem;
    }

    .btn-list {
      display: flex;
      width: 20rem;
      margin: auto;

      .el-button {
        position: unset;
        width: 100%;
        border: 2px solid #ffba31;
        border-radius: unset;
        color: #ffba31;
        background-color: #fff;

        &:active {
          border-color: #ffba31;
          color: #ffba31;
          background-color: #ffba31;
        }
      }

      .el-button + .el-button {
        margin-left: 0;
      }

      .is-active {
        color: #fff;
        background-color: #ffba31;
      }
    }

    .block {
      display: flex;
      align-items: center;
      justify-content: center;
      margin-top: 2rem;

      /deep/ .el-select {
        margin: 0 0.8rem;
      }

      /deep/ .el-input {
        width: 7.75rem;
      }

      .mark {
        font-weight: bolder;
        font-size: 1.2rem;
      }
    }
  }
}

@media screen and (max-width: 1540px) {
  .weekly-report {
    /deep/ .filter-bar {
      display: block;
    }

    /deep/ .el-form {
      margin-top: 1rem;
    }

    /deep/ .el-table .cell,
    .el-table th > .cell {
      padding-left: 0.625rem;
      font-size: 1.2vw;
    }

    /deep/ .el-table th:first-child .cell {
      padding-left: 1.05vw;
    }

    /deep/ .el-table td:first-child .cell {
      padding-left: 1.05vw;
    }
  }
}

@media screen and (max-width: 1420px) {
  .weekly-report {
    /deep/ .el-table .cell,
    .el-table th > .cell {
      font-size: 1.1vw;
    }

    /deep/ .el-table td .cell {
      font-size: 1.1vw;
    }
  }
}

@media screen and (max-width: 1345px) {
  .weekly-report {
    /deep/ .el-button {
      padding: 0 2.2rem;
    }

    /deep/ .filter-bar {
      .el-form {
        .el-form-item {
          margin-right: -4vw;
        }

        .el-form-item__content {
          width: 50%;
        }
      }
    }
  }
}

@media screen and (max-width: 1300px) {
  .weekly-report {
    /deep/ .layout {
      padding: 1.875rem 3.5rem 2.625rem;
    }

    /deep/ .filter-bar {
      flex-direction: column;
      align-items: flex-start;
    }

    /deep/ .el-table .cell,
    .el-table th > .cell {
      padding: 0 1.125vw;
      font-size: 1.3vw;
    }

    /deep/ .el-table td .cell {
      padding: 0 0.325vw;
      font-size: 1.3vw;
    }

    /deep/ .el-form-item__label {
      line-height: 3.825vw;
    }

    /deep/ .el-button {
      font-size: 1.525vw;
      line-height: 3.825vw;
    }

    // /deep/ .el-form-item__content {
    //   line-height: 3vw;
    // }
    /deep/ .el-input__inner {
      height: 3.925vw;
      font-size: 1.425vw;
      line-height: 3.825vw;
    }

    /deep/ .el-input__icon {
      width: 1.27vw;
      height: 3.925vw;
      line-height: 3.825vw;
    }

    /deep/ .el-date-editor .el-input__prefix {
      top: 1.15vw;
    }

    /deep/ .el-table td .cell .dashed {
      padding: 0.1426rem 0;
    }

    /deep/ .el-table th {
      padding: 1.2vw 0;
    }
  }
}
</style>
<style lang="scss">
.el-date-picker {
  width: 18.425rem;
}

.el-date-picker .el-picker-panel__content {
  width: 16.25rem;
  margin: 1.2rem 1rem;
}

.el-dropdown-menu {
  height: 15rem;
  overflow-y: scroll;

  &::-webkit-scrollbar {
    display: none;
  }
}
</style>
