<template>
  <div class="topic" v-loading.fullscreen.lock="loading">
    <w-layout>
      <template #header-text>
        問卷填寫紀錄
      </template>
      <div class="topic-management-title topic-rwd">
        <div class="left">
          <label>填寫人數 : <span class="total">{{surveResNum}}</span></label>
          <el-divider direction="vertical" />
          <label>總人數 : <span class="total">{{totalNum}}</span></label>
        </div>
        <div class="right">
          <el-form
            :inline="true"
            ref="dateForm"
            :model="dateForm"
            :rules="dateFormRules"
            :hide-required-asterisk="true"
          >
            <!-- <el-form-item label="問卷類型：" prop="startDate" label-width="120px">
              <el-select
                v-model="dateForm.startDate"
                placeholder="请选择活动区域"
              >
                <el-option label="区域一" value="shanghai"></el-option>
                <el-option label="区域二" value="beijing"></el-option>
              </el-select>
            </el-form-item> -->

            <el-form-item label="搜尋：" prop="searchText" label-width="80px">
              <el-input v-model="dateForm.searchText"></el-input>
            </el-form-item>

            <el-form-item>
              <el-button @click="validateDate('dateForm')">查詢</el-button>
              <el-button @click="resetData" class="clear-btn">清空</el-button>
              <el-button @click="excel">下載</el-button>
            </el-form-item>
          </el-form>
        </div>
      </div>
      <el-table :data="surveyData" border stripe style="width: 100%;">
        <el-table-column prop="name" label="用戶名單" min-width="20%">
        </el-table-column>
        <el-table-column prop="updateTime" label="填寫日期" min-width="20%">
        </el-table-column>
        <el-table-column prop="createAt" label="問卷類型" min-width="60%">
        </el-table-column>
      </el-table>
      <el-pagination
        background
        layout="prev, pager, next"
        :page-count="surveyPageCount"
        :current-page="surveyCurrentPage"
        :pager-count="7"
        @current-change="topicCurrentChange"
      />
    </w-layout>
  </div>
</template>
<script>
import WLayout from '@/components/Layout';
import backendApi from '@/assets/js/api/backendApi.js';
// import helper from '@/assets/js/util/helper';
import dayjs from 'dayjs';

export default {
  components: {
    WLayout,
  },
  data() {
    return {
      dateForm: {
        startDate: '',
        searchText: '',
      },
      dateFormRules: {
        // startDate: [
        //   {
        //     required: true,
        //     message: '請輸入開始日期',
        //     trigger: 'blur',
        //   },
        // ],
        searchText: [
          {
            required: false,
            message: '',
            trigger: 'blur',
          },
        ],
      },
      surveyData: [],
      loading: false,
      surveyCurrentPage: 1,
      surveyPageCount: 1,
      size: 10,
      searchingData: {
        startDate: '',
        searchText: '',
      },
      surveResNum: 0,
      totalNum: 0,
    };
  },
  mounted() {
    const vm = this;
    vm.getSurveyNumber();
    vm.getSurvey();
  },
  methods: {
    async getSurvey() {
      const vm = this;
      vm.loading = true;
      let data = {};
      data = vm.sendApiData();

      const res = await backendApi.getSurvey(data);
      if (res.code === 200) {
        vm.surveyData = [];
        vm.surveyCurrentPage = res.data.pageNumber;
        vm.surveyPageCount = res.data.totalPages;
        res.data.content.forEach((e) => {
          Object.keys(e).forEach((key) => {
            if (!e[key]) {
              e[key] = '-';
            } else if (key === 'updateTime') {
              e[key] = String(dayjs(e[key]).format('YYYY-MM-DD'));
            }
          });
          vm.surveyData.push(e);
        });
      }
      vm.loading = false;
    },
    async getSurveyNumber() {
      const vm = this;
      const res = await backendApi.getSurveyNumber();
      if (res.code === 200) {
        vm.surveResNum = res.data.surveResNum;
        vm.totalNum = res.data.totalNum;
      }
    },
    validateDate(formName) {
      const vm = this;
      vm.$refs[formName].validate((valid) => {
        if (valid) {
          vm.searchingData = JSON.parse(JSON.stringify(vm.dateForm));
          vm.surveyCurrentPage = 1;
          vm.getSurvey();
        }
        return false;
      });
    },
    topicCurrentChange(val) {
      const vm = this;
      vm.surveyCurrentPage = val;
      vm.getSurvey();
    },
    chooseLastDate(day) {
      const date = String(dayjs(day).format('YYYY-MM-DD'));
      const dateNumber = dayjs(date).daysInMonth();
      const dateArray = date.split('-');
      dateArray[dateArray.length - 1] = dateNumber;
      return dateArray.join('-');
    },
    resetData() {
      const vm = this;
      vm.searchingData.searchText = '';
      vm.dateForm.startDate = '';
      vm.dateForm.searchText = '';
      vm.surveyCurrentPage = 1;
      vm.getSurvey();
    },
    sendApiData() {
      const vm = this;
      let data = '';
      const currentPage = vm.surveyCurrentPage;
      if (vm.searchingData.searchText) {
        data = {
          page: currentPage,
          size: vm.size,
          searchText: vm.searchingData.searchText,
        };
      } else {
        data = {
          page: currentPage,
          size: vm.size,
        };
      }
      return data;
    },
    async excel() {
      const vm = this;
      vm.loading = true;
      let res = '';
      let data = {};
      let title = '';
      data = vm.sendApiData();

      title = '問卷填寫紀錄.xlsx';
      res = await backendApi.getSurveyExcel(data);
      if (res) {
        const a = document.createElement('a');
        const blob = new Blob([res], { type: 'application/excel' });
        a.href = window.URL.createObjectURL(blob);
        a.download = title;
        a.style.display = 'none';
        document.body.appendChild(a);
        a.click();
      }
      vm.loading = false;
    },
  },
};
</script>
<style lang="scss" scoped>
.button-container {
  display: flex;
  justify-content: space-between;
}

.topic-management-title {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: 25px;

  label {
    color: #23354d;
    font-weight: bold;
    font-size: 1.125rem;
    letter-spacing: 3.6px;
    cursor: pointer;
  }

  .left {
    label {
      color: #ffba31;
      font-size: 1rem;

      .total {
        font-size: 1.3rem;
      }
    }
  }
}

/deep/ .order-input.el-input {
  width: 70px;
  margin-left: -0.9rem;

  .el-input__inner {
    height: 1.875rem;
    padding: 0 0.75rem;
    border: solid 0.15rem #b5b5b5;
    border-radius: unset;
    line-height: 1.875rem;
    letter-spacing: 1.6px;
    background-color: transparent;
  }
}

/deep/ .el-table {
  margin-top: 1.5625rem;
}

/deep/ .filter-bar {
  margin-bottom: 1rem;
}

/deep/ .el-divider--vertical {
  width: 0.3625rem;
  height: 1.8rem;
  margin: 0 1rem;
  border-radius: 28.5%;
  background-color: #ffba31;
}

/deep/ .el-button.main-btn {
  border: solid 0.15rem #ffba31;
  background-color: #ffba31;
}

/deep/ .el-button.main-btn-unchecked {
  border: solid 0.15rem #ffba31;
  color: #ffba31;
  background-color: #fff;
}

.clear-btn {
  background-color: #ccc;

  &:hover {
    background-color: #949494;
  }
}

/deep/ .el-dialog.topic-dialog {
  .single-text {
    width: fit-content;
    margin: 0 auto;
    color: #333;
    font-weight: bold;
    font-size: 1rem;
    letter-spacing: 1.6px;
  }

  .el-dialog__body {
    padding: 0 6.25rem 1.875rem;
  }

  .el-input {
    width: 100%;
  }

  .el-input__inner {
    font-size: 1.125rem;
    letter-spacing: 1.8px;
  }

  .el-form-item__label {
    padding: 0;
    font-size: 1.25rem;
  }

  .el-dialog__footer {
    padding: 0.625rem 1.25rem 2.2rem;
  }
}

@media screen and(max-width: 1790px) {
  .topic-management-title {
    display: block;

    .left {
      margin-bottom: 1.5625rem;
    }

    /deep/ .el-form-item__label {
      letter-spacing: 0.225rem;
      text-align: left;
    }
  }
}

@media screen and(max-width: 1610px) {
  .topic-rwd {
    display: block;

    .left {
      margin-bottom: 1.5625rem;
    }

    /deep/ .el-form-item__label {
      letter-spacing: 0.225rem;
      text-align: left;
    }
  }
}

@media screen and(max-width: 1538px) {
  .topic-rwd {
    /deep/ .el-form {
      .el-form-item {
        &:last-child {
          margin-top: 1.5625rem;
        }
      }
    }
  }
}
</style>
