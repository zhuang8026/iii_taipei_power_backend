<template>
  <div class="admin" v-loading="loading">
    <w-layout>
      <template #header-text>
        用戶查詢
      </template>
      <template #filter>
        <el-button @click="openAddMemberDialog">新增用戶</el-button>
      </template>
      <div class="filter-row">
        <div class="filter-col">
          <label>帳號:</label>
          <el-input v-model="search.account" placeholder="請輸入" />
        </div>
        <div class="filter-col">
          <label>姓名:</label>
          <el-input v-model="search.name" placeholder="請輸入" />
        </div>
        <div class="filter-col">
          <label>手機:</label>
          <el-input v-model="search.phone" placeholder="請輸入" />
        </div>
        <div class="filter-col">
          <label>信箱:</label>
          <el-input v-model="search.email" placeholder="請輸入" />
        </div>
      </div>
      <div class="filter-row">
        <div class="filter-col">
          <label>Gateway:</label>
          <el-input v-model="search.gatewayId" placeholder="請輸入" />
        </div>
        <div class="filter-col">
          <el-button @click="getSearch">
            查詢
          </el-button>
          <el-button @click="clear" class="btn-cancel-color">
            清空
          </el-button>
        </div>
      </div>
      <div class="ui-table">
        <el-table :data="userData" border stripe>
          <el-table-column width="300" prop="userName" label="帳號" />
          <el-table-column prop="password" label="密碼" />
          <el-table-column width="100" label="姓名">
            <template slot-scope="scope">
              {{ scope.row.name || '-' }}
            </template>
          </el-table-column>
          <el-table-column width="175" label="手機">
            <template slot-scope="scope">
              {{ scope.row.userPhone || '-' }}
            </template>
          </el-table-column>
          <el-table-column width="300" label="信箱">
            <template slot-scope="scope">
              {{ scope.row.email || '-' }}
            </template>
          </el-table-column>
          <el-table-column label="Gateway">
            <template slot-scope="scope">
              {{ scope.row.gatewayId || '-' }}
            </template>
          </el-table-column>
          <el-table-column label="NTPC">
            <template slot-scope="scope">
              {{ scope.row.belongNtpc || '-' }}
            </template>
          </el-table-column>
          <el-table-column width="125" label="操作">
            <template slot-scope="scope">
              <div class="button-container">
                <el-button
                  :disabled="scope.row.belongNtpc !== 'ntpc3'"
                  class="small-btn btn-main-color"
                  @click="openEditDialog(scope.row)"
                >
                  修改
                </el-button>
              </div>
            </template>
          </el-table-column>
        </el-table>
      </div>
      <el-pagination
        background
        :page-size="size"
        :current-page.sync="page"
        layout="prev, pager, next"
        :pager-count="7"
        :total="Number(totalElements)"
        @current-change="currentPageChange"
      />
    </w-layout>
    <bind-device-dialog
      v-model="showBindDeviceDialog"
      :device-list="deviceList"
      :device-info="deviceInfo"
      show-gateway
    />
    <add-member v-model="showAddMemberDialog" :device-list="deviceList" />
  </div>
</template>
<script>
import WLayout from '@/components/Layout';
import backendApi from '@/assets/js/api/backendApi.js';
import BindDeviceDialog from '@/components/BindDevice';
import AddMember from '@/components/AddMember';

export default {
  meta: {
    ntpcMode: true,
  },
  components: {
    WLayout,
    BindDeviceDialog,
    AddMember,
  },
  data() {
    return {
      search: {
        name: '', // 模糊搜尋
        phone: '', // 模糊搜尋
        gatewayId: '', // 模糊搜尋
        email: '', // 模糊搜尋
        account: '', // 模糊搜尋
      },
      searching: {
        name: '',
        phone: '',
        gatewayId: '',
        email: '',
        account: '',
      },
      loading: false,
      userData: [],
      totalElements: 10,
      page: 1,
      size: 10,
      showBindDeviceDialog: false,
      showAddMemberDialog: false,
      deviceList: [],
      deviceInfo: [],
    };
  },
  mounted() {
    const vm = this;
    vm.getManagerList();
  },
  methods: {
    openEditDialog(row) {
      const vm = this;
      Promise.all([vm.getDeviceList(), vm.getManagerInfo(row)]).then((res) => {
        if (res.some((e) => !e)) return;
        vm.showBindDeviceDialog = true;
      });
    },
    async getDeviceList() {
      const vm = this;
      const res = await backendApi.getDeviceList();
      if (res.code === 200) {
        vm.deviceList = [...res.data];
      } else if (res.code === 4011) {
        return false;
      }
      return true;
    },
    async getManagerInfo({ userName, belongNtpc }) {
      const vm = this;
      const obj = {
        userId: userName,
        ntpc: belongNtpc,
      };
      const res = await backendApi.getManagerInfo(obj);
      if (res.code === 200) {
        vm.deviceInfo = [...res.data];
      } else if (res.code === 4011) {
        return false;
      } else {
        vm.deviceInfo = [];
      }
      return true;
    },
    currentPageChange(val) {
      const vm = this;
      vm.page = val;
      vm.getManagerList();
    },
    async getManagerList() {
      const vm = this;
      vm.loading = true;
      const obj = {
        page: vm.page,
        size: vm.size,
        ...vm.searching,
      };
      const res = await backendApi.getManagerList(obj);
      if (res.code === 200) {
        vm.userData = [...res.data.content];
        vm.totalElements = res.data.totalElements;
      }
      vm.loading = false;
    },
    getSearch() {
      const vm = this;
      vm.page = 1;
      vm.searching = { ...vm.search };
      vm.getManagerList();
    },
    clear() {
      const vm = this;
      if (Object.keys(vm.search).every((key) => !vm.search[key])) return;
      Object.keys(vm.search).forEach((key) => {
        vm.search[key] = '';
      });
      vm.reset();
      vm.getManagerList();
    },
    reset() {
      const vm = this;
      Object.keys(vm.searching).forEach((key) => {
        vm.searching[key] = '';
      });
      vm.page = 1;
    },
    openAddMemberDialog() {
      const vm = this;

      vm.getDeviceList();
      vm.showAddMemberDialog = true;
    },
  },
};
</script>

<style lang="scss" scoped>
.admin {
  height: 100%;
  font-family: Noto Sans CJK TC, sans-serif;
}

.filter {
  &-row {
    display: flex;
    flex-wrap: wrap;
    gap: 0 15px;
    margin-bottom: 15px;

    &:nth-child(2) {
      justify-content: space-between;
    }
  }

  &-col {
    display: flex;
    flex-basis: calc(25% - 15px * 3 / 4);
    gap: 0 10px;
    align-items: center;

    label {
      flex-shrink: 0;
    }

    /deep/ .el-button {
      width: 50%;
    }

    /deep/ .el-input {
      width: 100%;
    }
  }
}

.button-container {
  display: flex;
  justify-content: center;
}
</style>
